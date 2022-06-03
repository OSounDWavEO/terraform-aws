// App servers
resource "aws_instance" "app" {
	count = var.ec2_app_count

	// Wrap-around private app subnets to provision app servers, start from private app subnet 0 or private app subnet 1 if admin server is dedicated and provision to subnet 0
	subnet_id				= element(data.aws_subnet.private_app[*].id, count.index + (var.separate_admin ? 1 : 0))
	availability_zone		= element(data.aws_subnet.private_app[*].availability_zone, count.index + (var.separate_admin ? 1 : 0))
	ami						= local.ec2_ami
	instance_type			= var.ec2_app_size
	key_name				= var.key_pair
	vpc_security_group_ids	= local.ec2_security_groups
	source_dest_check		= true
	disable_api_termination	= true

	// EBS optimized is only allowed for t3 or large instances
	ebs_optimized			= substr(var.ec2_app_size, 0, 2) == "t3" || substr(var.ec2_app_size, -5, -1) == "large" ? true : false

	root_block_device {
		volume_type				= "gp2"
		volume_size				= var.ec2_app_storage
		delete_on_termination	= true
	}

	credit_specification {
		cpu_credits	= "standard"
	}

	tags	= merge(var.tags, {
		Name		= "${var.prefix}-${!var.separate_admin && count.index == 0 ? "admin-" : ""}app-${format("%02d", count.index)}"
		Zone		= "Private"
		Group		= "${var.prefix}-app"
		DefaultSize	= var.ec2_app_size
	})

	volume_tags	= merge(var.tags, {
		Name		= "${var.prefix}-${!var.separate_admin && count.index == 0 ? "admin-" : ""}app-${format("%02d", count.index)}-os"
		Instance	= "${var.prefix}-${!var.separate_admin && count.index == 0 ? "admin-" : ""}app-${format("%02d", count.index)}"
		Zone		= "Private"
	})

	lifecycle {
		ignore_changes = [ami, availability_zone, subnet_id]
	}
}

// Admin server, provision if separate_admin is true otherwise first app server is also served as admin server
resource "aws_instance" "admin" {
	count = var.separate_admin ? 1 : 0

	// Search subnet_id (key) from availability_zone (value) and choose the first subnet matched
	subnet_id				= data.aws_subnet.private_app[index(data.aws_subnet.private_app[*].availability_zone, var.ec2_admin_az)].id
	availability_zone		= var.ec2_admin_az
	ami						= local.ec2_ami
	instance_type			= var.ec2_admin_size
	key_name				= var.key_pair
	vpc_security_group_ids	= local.ec2_security_groups
	source_dest_check		= true
	disable_api_termination	= true

	// EBS optimized is only allowed for t3 or large instances
	ebs_optimized			= substr(var.ec2_admin_size, 0, 2) == "t3" || substr(var.ec2_admin_size, -5, -1) == "large" ? true : false

	root_block_device {
		volume_type				= "gp2"
		volume_size				= var.ec2_admin_storage
		delete_on_termination	= true
	}

	credit_specification {
		cpu_credits	= "standard"
	}

	tags	= merge(var.tags, {
		Name		= "${var.prefix}-admin"
		Zone		= "Private"
		Group		= "${var.prefix}-admin"
		DefaultSize	= var.ec2_admin_size
	})

	volume_tags	= merge(var.tags, {
		Name		= "${var.prefix}-admin-os"
		Instance	= "${var.prefix}-admin"
		Zone		= "Private"
	})

	lifecycle {
		ignore_changes = [ami, availability_zone, subnet_id]
	}
}

locals {
	// Provision NFS server in the same subnet as admin server
	ec2_nfs_az	= coalesce(join("", aws_instance.admin[*].availability_zone), aws_instance.app[0].availability_zone)
}

// NFS server, provision if separate_nfs is true
resource "aws_instance" "nfs" {
	count = var.separate_nfs ? 1 : 0

	availability_zone		= local.ec2_nfs_az
	subnet_id				= data.aws_subnet.private_app[index(data.aws_subnet.private_app[*].availability_zone, local.ec2_nfs_az)].id
	ami						= local.ec2_ami
	instance_type			= var.ec2_nfs_size
	key_name				= var.key_pair
	vpc_security_group_ids	= local.ec2_security_groups
	source_dest_check		= true
	disable_api_termination	= true

	// EBS optimized is only allowed for t3 or large instances
	ebs_optimized			= substr(var.ec2_nfs_size, 0, 2) == "t3" || substr(var.ec2_nfs_size, -5, -1) == "large" ? true : false

	root_block_device {
		volume_type				= "gp2"
		volume_size				= var.ec2_nfs_storage
		delete_on_termination	= true
	}

	credit_specification {
		cpu_credits	= "standard"
	}

	tags	= merge(var.tags, {
 		Name			= "${var.prefix}-nfs"
		Zone			= "Private"
		Group			= "${var.prefix}-nfs"
		DefaultSize		= var.ec2_nfs_size
	})

	volume_tags	= merge(var.tags, {
		Name		= "${var.prefix}-nfs-os"
		Instance	= "${var.prefix}-nfs"
		Zone		= "Private"
	})

	lifecycle {
		ignore_changes = [ami, availability_zone, subnet_id, ebs_optimized]
	}
}

resource "aws_db_subnet_group" "db_group" {
	count	= signum(var.db_count)

	name		= var.prefix
	description	= "Private subnets for RDS instance"
	subnet_ids	= var.subnets["private_data"]

	tags	= merge(var.tags, {
		Name	= "${var.prefix}-db-group"
		Zone	= "Private"
	})

	lifecycle {
		ignore_changes	= [name]
	}
}

// Primary db for non-aurora-mysql, not provision if db_count = 0
resource "aws_db_instance" "db_primary" {
	count	= var.db_engine != "aurora-mysql" && var.db_count > 0 ? 1 : 0

	identifier						= "${var.prefix}-00"
	allocated_storage				= var.db_storage
	storage_type					= "gp2"
	engine							= var.db_engine
	engine_version					= var.db_engine_version
	instance_class					= var.db_primary_size
	username						= var.db_master_username
	password						= "PleaseChangeYourPassword"
	vpc_security_group_ids			= [var.security_groups["mysql_private_app_subnets"]]
	db_subnet_group_name			= aws_db_subnet_group.db_group[0].id
	parameter_group_name			= var.db_parameter
	backup_retention_period			= 7
	publicly_accessible				= false
	multi_az						= var.db_multi_az
	copy_tags_to_snapshot			= true
	final_snapshot_identifier		= "${var.prefix}-final"
	auto_minor_version_upgrade		= false
	apply_immediately				= true
	deletion_protection				= true
	performance_insights_enabled	= true

	tags	= merge(var.tags, {
		Name			= "${var.prefix}-db-00"
		Group			= "${var.prefix}-db"
		DefaultSize		= var.db_primary_size
	})

	lifecycle {
		ignore_changes = [engine_version, username, identifier, password]
	}
}

// Primary db for non-aurora-mysql, provision if db_count > 1
resource "aws_db_instance" "db_replica" {
	// initiate loop
	count	= var.db_engine != "aurora-mysql" && var.db_count > 0 ? var.db_count - 1 : 0

	identifier						= "${var.prefix}-${format("%02d", count.index + 2)}"
	storage_type					= "gp2"
	instance_class					= var.db_replica_size
	vpc_security_group_ids			= [var.security_groups["mysql_private_app_subnets"]]
	backup_retention_period			= 0
	publicly_accessible				= false
	copy_tags_to_snapshot			= true
	replicate_source_db				= aws_db_instance.db_primary[0].identifier
	auto_minor_version_upgrade		= false
	apply_immediately				= true
	deletion_protection				= true
	performance_insights_enabled	= true

	tags	= merge(var.tags, {
		Name			= "${var.prefix}-db-${format("%02d", count.index + 1)}"
		Group			= "${var.prefix}-db"
		DefaultSize		= var.db_replica_size
	})
}

// Cluster for aurora-mysql
resource "aws_rds_cluster" "db_cluster" {
	count	= var.db_engine == "aurora-mysql" && var.db_count > 0 ? 1 : 0

	cluster_identifier				= var.prefix
	master_username					= var.db_master_username
	master_password					= "PleaseChangeYourPassword"
	final_snapshot_identifier		= "${var.prefix}-final"
	engine							= "aurora-mysql"
	backup_retention_period			= 7
	vpc_security_group_ids			= [var.security_groups["mysql_private_app_subnets"]]
	apply_immediately				= true
	db_subnet_group_name			= aws_db_subnet_group.db_group[0].id
	db_cluster_parameter_group_name	= var.db_parameter
	deletion_protection				= true

	tags	= merge(var.tags, {
		Name	= "${var.prefix}-db-cluster"
		Zone	= "Private"
		Group	= "${var.prefix}-db-cluster"
	})

	lifecycle {
		ignore_changes = [engine_version, master_username, cluster_identifier, master_password]
	}
}

// Primary db for aurora-mysql, not provision if db_count = 0
resource "aws_rds_cluster_instance" "db_primary" {
	count	= var.db_engine == "aurora-mysql" && var.db_count > 0 ? 1 : 0

	identifier						= "${var.prefix}-00"
	cluster_identifier				= aws_rds_cluster.db_cluster[0].id
	engine							= "aurora-mysql"
	instance_class					= var.db_primary_size
	promotion_tier					= 0
	db_subnet_group_name			= aws_db_subnet_group.db_group[0].id
	db_parameter_group_name			= var.db_parameter
	apply_immediately				= true
	performance_insights_enabled	= true
	auto_minor_version_upgrade		= false

	tags	= merge(var.tags, {
		Name			= "${var.prefix}-db-00"
		Group			= "${var.prefix}-db"
		DefaultSize		= var.db_primary_size
	})

	lifecycle {
		ignore_changes = [engine_version]
	}
}

// Replica db for aurora-mysql, provision if db_count > 1
resource "aws_rds_cluster_instance" "db_replica" {
	count	= var.db_engine == "aurora-mysql" && var.db_count > 0 ? var.db_count - 1 : 0

	identifier						= "${var.prefix}-${format("%02d", count.index + 1)}"
	cluster_identifier				= aws_rds_cluster.db_cluster[0].id
	engine							= "aurora-mysql"
	instance_class					= var.db_replica_size
	promotion_tier					= count.index + 1
	db_subnet_group_name			= aws_db_subnet_group.db_group[0].id
	db_parameter_group_name			= var.db_parameter
	apply_immediately				= true
	performance_insights_enabled	= false
	auto_minor_version_upgrade		= false

	tags	= merge(var.tags, {
		Name			= "${var.prefix}-db-${format("%02d", count.index + 1)}"
		Group			= "${var.prefix}-db"
		DefaultSize		= var.db_replica_size
	})

	lifecycle {
		ignore_changes = [engine_version]
	}
}

resource "aws_elasticache_subnet_group" "redis_group" {
	count	= signum(var.redis_count)

	name		= var.prefix
	description	= "Private subnets for ElastiCache instances"
	subnet_ids	= var.subnets["private_data"]

	lifecycle {
		ignore_changes = [name]
	}
}

// Replica db for aurora-mysql, not provision if redis_count = 0
resource "aws_elasticache_replication_group" "redis" {
	count	= var.redis_count

	replication_group_id			= var.prefix
	replication_group_description	= "Redis servers"
	node_type						= var.redis_size
	engine_version					= var.redis_engine_version
	subnet_group_name				= aws_elasticache_subnet_group.cache_group[0].name
	security_group_ids				= [var.security_groups["redis_private_app_subnets"]]
	number_cache_clusters			= var.redis_count
	port							= 6379
	parameter_group_name			= var.redis_parameter
	apply_immediately				= true

	tags	= merge(var.tags, {
		Name			= "${var.prefix}-redis"
		Group			= "${var.prefix}-redis"
		DefaultSize		= var.redis_size
	})

	lifecycle {
		ignore_changes = [replication_group_id, subnet_group_name, engine_version, parameter_group_name]
	}
}