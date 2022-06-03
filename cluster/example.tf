variable "key_pair" {
	type		= string
	description	= "Name of key pair"
}

variable "tags" {
	type		= map(string)
	description	= "Tags"
	default		= {
		Project		= "Example"
		Environment	= "Production"
	}
}

module "example_vpc" {
	source	= "../modules/network_resources"
	
	prefix		= "prod-example"
	vpc_cidr	= "10.0.0.0/24"

	tags	= var.tags
}

module "example_alb" {
	source	= "../modules/load_balancer_resources"

	vpc				= module.example_vpc.vpc
	alb_subnets		= module.example_vpc.subnets["public_dmz"]
	security_groups	= [module.example_vpc.security_groups["http_s_all"]]

	name				= "prod-example"
	log_prefix			= "www.example.com" // require S3 bucket named access-log
	ssl_certificates	= ["www.example.com"] // require a SSL certificate in AWS ACM
	default_group		= "app"

	target_groups	= {
		nfs	= {
			priority			= 1
			protocol			= "HTTP"
			port				= 80
			healthcheck_path	= "/"
			target_servers		= module.example_hosting.ec2_nfs_id

			conditions	= {
				path_pattern	= ["/media*"]
			}
		}
		admin	= {
			priority			= 2
			protocol			= "HTTP"
			port				= 80
			healthcheck_path	= "/admin"
			target_servers		= module.example_hosting.ec2_admin_id

			conditions	= {
				path_pattern	= ["/admin*"]
			}
		}
		app		= {
			priority			= 0
			protocol			= "HTTP"
			port				= 80
			healthcheck_path	= "/"
			target_servers		= module.example_hosting.ec2_app_id

			conditions	= {}
		}
	}

	tags	= var.tags
}

module "example_hosting" {
	source	= "../modules/hosting_resources/small"

	vpc						= module.example_vpc.vpc
	subnets					= module.example_vpc.subnets
	security_groups			= module.example_vpc.security_groups
	internal_root_domain	= "example.com"
	key_pair				= var.key_pair
	prefix					= "prod-example"
	tags					= var.tags
}