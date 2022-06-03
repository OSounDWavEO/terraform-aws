output "vpc" {
	value	= aws_vpc.vpc.id
}

output "subnets" {
	value	= {
		public_dmz		= aws_subnet.public_dmz[*].id
		private_app		= aws_subnet.private_app[*].id
		private_data	= aws_subnet.private_data[*].id
	}
}

output "security_groups" {
	value	= {
		internal					= aws_default_security_group.internal.id
		http_s_public_dmz			= aws_security_group.http_s_public_dmz.id
		http_s_all					= aws_security_group.http_s_all.id
		mysql_private_app_subnets	= aws_security_group.mysql_private_app_subnets.id
		redis_private_app_subnets	= aws_security_group.redis_private_app_subnets.id
	}
}