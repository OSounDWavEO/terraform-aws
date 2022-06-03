module "template_module" {
	source	= "../"

	vpc						= var.vpc
	subnets					= var.subnets
	security_groups			= var.security_groups
	az						= var.az
	internal_root_domain	= var.internal_root_domain
	key_pair				= var.key_pair
	prefix					= var.prefix
	tags					= var.tags
	
	ec2_ami				= var.ec2_ami
	ec2_placement_group	= var.ec2_placement_group
	ec2_security_groups	= var.ec2_security_groups

	ec2_app_count	= var.ec2_app_count
	ec2_app_size	= var.ec2_app_size
	ec2_app_storage	= var.ec2_app_storage

	separate_admin	= var.separate_admin

	ec2_admin_az		= var.ec2_admin_az
	ec2_admin_size		= var.ec2_admin_size
	ec2_admin_storage	= var.ec2_admin_storage

	separate_nfs	= var.separate_nfs

	ec2_nfs_az			= var.ec2_nfs_az
	ec2_nfs_size		= var.ec2_nfs_size
	ec2_nfs_storage	= var.ec2_nfs_storage
	
	db_engine			= var.db_engine
	db_engine_version	= var.db_engine_version
	db_multi_az			= var.db_multi_az
	db_parameter		= var.db_parameter
	db_count			= var.db_count
	db_primary_size		= var.db_primary_size
	db_replica_size		= var.db_replica_size
	db_storage			= var.db_storage
	db_master_username	= var.db_master_username
	
	redis_count				= var.redis_count
	redis_engine_version	= var.redis_engine_version
	redis_parameter			= var.redis_parameter
	redis_size				= var.redis_size
}