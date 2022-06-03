output "ec2_admin_id" {
	value	= [coalesce(join("", aws_instance.admin[*].id), aws_instance.app[0].id)]
}

output "ec2_admin_internal_dns" {
	value	= aws_route53_record.internal_admin.fqdn
}

output "ec2_app_id" {
	value	= aws_instance.app[*].id
}

output "ec2_app_internal_dns" {
	value	= aws_route53_record.internal_app[*].fqdn
}

output "ec2_nfs_id" {
	value	= aws_instance.nfs[*].id
}

output "ec2_nfs_internal_dns" {
	value	= aws_route53_record.internal_nfs[*].fqdn
}

output "db_subnet_group_id" {
	value	= aws_db_subnet_group.db_group[0].id
}

output "redis_subnet_group_name" {
	value	= aws_elasticache_subnet_group.redis_group[0].name
}