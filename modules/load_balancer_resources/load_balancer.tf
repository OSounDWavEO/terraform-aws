// Provision application load balancer in public DMZ subnets
resource "aws_lb" "alb" {
	name		= var.name
	internal	= false
	subnets		= var.alb_subnets

	enable_deletion_protection	= true

	security_groups	= var.security_groups
	idle_timeout	= var.idle_timeout
	enable_http2	= var.http2_enable

	dynamic "access_logs" {
		for_each	= var.log_prefix == null ? [] : [1]

		content {
			bucket	= "access-log"
			prefix	= var.log_prefix
			enabled	= true
		}
	}

	tags	= merge(var.tags, {
		Name	= "${var.name}-alb"
		Zone	= "Public"
	})

	lifecycle {
		ignore_changes = [name]
	}
}

// Create target groups
resource "aws_lb_target_group" "group" {
	for_each	= var.target_groups

	name		= "${var.name}-${each.key}"
	port		= each.value["port"]
	protocol	= each.value["protocol"]
	vpc_id		= var.vpc

	health_check {
		path	= each.value["healthcheck_path"]
		matcher	= "200,301,302"
	}

	tags	= merge(var.tags, {
		Name	= "${var.name}-alb-${each.key}"
		Zone	= "Public"
	})

	lifecycle {
		ignore_changes = [name]
	}
}

// Create HTTP listener, mutual exclusive with http_redirect listener
resource "aws_lb_listener" "http" {
	count	= length(var.ssl_certificates) == 0 ? 1 : 0

	load_balancer_arn	= aws_lb.alb.arn
	port				= "80"
	protocol			= "HTTP"

	default_action {
		type				= "forward"
		target_group_arn	= aws_lb_target_group.group[var.default_group].arn
	}
}

// Redirect HTTP to HTTPS mutual exclusive with http listener
resource "aws_lb_listener" "http_redirect" {
	count	= signum(length(var.ssl_certificates)) 

	load_balancer_arn	= aws_lb.alb.arn
	port				= "80"
	protocol			= "HTTP"

	default_action {
		type	= "redirect"

		redirect {
			port		= 443
			protocol	= "HTTPS"
			status_code	= "HTTP_301"
		}
	}
}

// Create HTTPS listener
resource "aws_lb_listener" "https" {
	count	= signum(length(var.ssl_certificates)) 

	load_balancer_arn	= aws_lb.alb.arn
	port				= "443"
	protocol			= "HTTPS"
	ssl_policy			= "ELBSecurityPolicy-FS-1-2-Res-2019-08"
	certificate_arn		= data.aws_acm_certificate.ssl[0].arn

	default_action {
		type				= "forward"
		target_group_arn	= aws_lb_target_group.group[var.default_group].arn
	}

	lifecycle {
		ignore_changes = [ssl_policy]
	}
}

// Add other SSL certificates to HTTPS listener
resource "aws_lb_listener_certificate" "additional_ssl" {
	count	= (length(var.ssl_certificates) - 1) < 0 ? 0 : (length(var.ssl_certificates) - 1)

	listener_arn	= aws_lb_listener.https[0].arn
	certificate_arn	= data.aws_acm_certificate.ssl[count.index + 1].arn
}

// Create listerner rules
resource "aws_lb_listener_rule" "group_forward" {
	for_each	= {for name, params in var.target_groups : name => params if name != var.default_group}

	listener_arn	= length(var.ssl_certificates) == 0 ? aws_lb_listener.http[0].arn : aws_lb_listener.https[0].arn
	priority		= each.value["priority"]

	action {
		target_group_arn	= aws_lb_target_group.group[each.key].arn
		type				= "forward"
	}

	condition {
		dynamic "path_pattern" {
			for_each	= length(lookup(each.value["conditions"], "path_pattern", [])) > 0 ? [true] : []

			content {
				values	= each.value["conditions"]["path_pattern"]
			}
		}

		dynamic "host_header" {
			for_each	= length(lookup(each.value["conditions"], "host_header", [])) > 0 ? [true] : []

			content {
				values	= each.value["conditions"]["host_header"]
			}
		}

		dynamic "http_request_method" {
			for_each	= length(lookup(each.value["conditions"], "http_request_method", [])) > 0 ? [true] : []

			content {
				values	= each.value["conditions"]["http_request_method"]
			}
		}

		dynamic "source_ip" {
			for_each	= length(lookup(each.value["conditions"], "source_ip", [])) > 0 ? [true] : []

			content {
				values	= each.value["conditions"]["source_ip"]
			}
		}
	}
}

locals {
	target_groups_matching	= flatten([for target_group, params in var.target_groups :
		[for ec2 in params["target_servers"] :
			{
				target_group	= aws_lb_target_group.group[target_group].arn
				ec2				= ec2
			}]
	])
}

resource "aws_lb_target_group_attachment" "target_servers" {
	count	= length(local.target_groups_matching)

	target_group_arn	= local.target_groups_matching[count.index]["target_group"]
	target_id			= local.target_groups_matching[count.index]["ec2"]

	lifecycle {
		create_before_destroy	= true
	}
}