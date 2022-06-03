variable "name" {
	type		= string
	description	= "Load balancer's name"
}

variable "vpc" {
	type		= string
	description	= "VPC ID"
}

variable "alb_subnets" {
	type		= list(string)
	description	= "List of subnets for placing load balancer"
}

variable "tags" {
	type		= map(string)
	description	= "Resource's tags"
}

variable "http2_enable" {
	type		= bool
	description	= "Allow HTTP2 connection"
	default		= true
}

variable "idle_timeout" {
	type		= number
	description	= "Load balancer's idle timeout"
	default		= 600
}

variable "log_prefix" {
	type		= string
	description	= "Path in hosting-accesslog S3 bucket to keep load balancer access logs"
}

variable "default_group" {
	type		= string
	description	= "Default target group"
}

variable "target_groups" {
	type		= map(object({
		priority			= number
		protocol			= string
		port				= number
		healthcheck_path	= string
		target_servers		= list(string)
		conditions			= map(list(string))
	}))

	description	= "Target group details"
	default		= {
		default	= {
			priority			= 0
			protocol			= "HTTP"
			port				= 80
			healthcheck_path	= "/"
			target_servers		= []
			conditions			= {}
		}
	}
}

variable "security_groups" {
	type		= list(string)
	description	= "Security groups for application EC2 instance. Default is HTTP/S"
	default		= []
}

variable "ssl_certificates" {
	type		= list(string)
	description	= "List of SSL certificates"
}