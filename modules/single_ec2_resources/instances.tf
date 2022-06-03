resource "aws_instance" "single" {
	ami							= local.ami
	availability_zone			= data.aws_subnet.subnet.availability_zone
	instance_type				= var.size
	key_name					= var.key_pair
	vpc_security_group_ids		= var.security_groups
	subnet_id					= data.aws_subnet.subnet.id
	source_dest_check			= true
	disable_api_termination		= true
	ebs_optimized				= substr(var.size, 0, 2) == "t3" || substr(var.size, -5, -1) == "large" ? true : false
	
	root_block_device {
		volume_type				= "gp2"
		volume_size				= var.storage
		delete_on_termination	= true
	}

	credit_specification {
		cpu_credits	= "standard"
	}

	tags	= merge(var.tags, {
		Name			= join("-", compact([var.prefix, var.admin_role ? "admin" : "", var.app_role ? "app-${format("%02d", var.app_number)}" : ""]))
		Zone			= var.public_accessible ? "Public" : "Private"
		Group			= join("-", [var.prefix, var.app_role ? "app" : "admin"])
		DefaultSize		= var.size
	})
	
	volume_tags	= merge(var.tags, {
		Name		= join("-", compact([var.prefix, var.admin_role ? "admin" : "", var.app_role ? "app-${format("%02d", var.app_number)}" : "", "os"]))
		Instance	= join("-", compact([var.prefix, var.admin_role ? "admin" : "", var.app_role ? "app-${format("%02d", var.app_number)}" : ""]))
		Zone		= var.public_accessible ? "Public" : "Private"
	})

	lifecycle {
		ignore_changes	= [ami, instance_type, subnet_id, availability_zone]
	}
}

resource "aws_route53_record" "internal_admin" {
	count	= var.admin_role ? 1 : 0

	zone_id	= data.aws_route53_zone.internal_zone.id
	name	= "${var.prefix}-admin.${var.internal_root_domain}"
	type	= "A"
	ttl		= "300"
	records	= [aws_instance.single.private_ip]
}

// If frontend_allowed set to true
resource "aws_route53_record" "internal_app" {
	count	= var.app_role ? 1 : 0

	zone_id	= data.aws_route53_zone.internal_zone.id
	name	= "${var.prefix}-app-${format("%02d", var.app_number)}.${var.internal_root_domain}"
	type	= "A"
	ttl		= "300"
	records	= [aws_instance.single.private_ip]
}

// If public_accessible set to true
resource "aws_eip" "eip" {
	count	= var.public_accessible ? 1 : 0

	vpc	= true

	tags	= merge(var.tags, {
		Name		= join("-", compact([var.prefix, var.admin_role ? "admin" : "", var.app_role ? "app-${format("%02d", var.app_number)}" : "", "ip"]))
		Instance	= join("-", compact([var.prefix, var.admin_role ? "admin" : "", var.app_role ? "app-${format("%02d", var.app_number)}" : ""]))
		Zone		= "Public"
	})
}

resource "aws_eip_association" "eip_assoc" {
	count	= var.public_accessible ? 1 : 0

	instance_id		= aws_instance.single.id
	allocation_id	= aws_eip.eip[0].id
}

output id {
	value	= aws_instance.single.id
}

output private_ip {
	value	= aws_instance.single.private_ip
}