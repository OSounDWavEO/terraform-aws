// Get Route53 zone
resource "aws_route53_zone_association" "internal_zone_assoc" {
	zone_id	= data.aws_route53_zone.internal_zone.zone_id
	vpc_id	= var.vpc
}

// Internal DNS for App servers
resource "aws_route53_record" "internal_app" {
	count	= var.ec2_app_count

	zone_id	= data.aws_route53_zone.internal_zone.zone_id
	name	= "${var.prefix}-app-${format("%02d", count.index)}.${var.internal_root_domain}"
	type	= "A"
	ttl		= "300"
	records	= [aws_instance.app[count.index].private_ip]

	lifecycle {
		ignore_changes = [name]
	}
}

// Internal DNS for admin server, if not provision, it will point to the first app server instead
resource "aws_route53_record" "internal_admin" {
	zone_id	= data.aws_route53_zone.internal_zone.zone_id
	name	= "${var.prefix}-admin.${var.internal_root_domain}"
	type	= "A"
	ttl		= "300"
	records	= [coalesce(join("", aws_instance.admin[*].private_ip), aws_instance.app[0].private_ip)]

	lifecycle {
		ignore_changes = [name]
	}
}

// Internal DNS for NFS server, not create if separate nfs is false
resource "aws_route53_record" "internal_nfs" {
	count	= var.separate_nfs ? 1 : 0

	zone_id	= data.aws_route53_zone.internal_zone.zone_id
	name	= "${var.prefix}-nfs.${var.internal_root_domain}"
	type	= "A"
	ttl		= "300"
	records = [aws_instance.nfs[0].private_ip]

	lifecycle {
		ignore_changes = [name]
	}
}

// Internal DNS for non-aurora-mysql primary database server, not create if db_count = 0
resource "aws_route53_record" "internal_db" {
	count	= var.db_engine != "aurora-mysql" && var.db_count > 0 ? 1 : 0

	zone_id	= data.aws_route53_zone.internal_zone.zone_id
	name	= "${var.prefix}-db-00.${var.internal_root_domain}"
	type	= "CNAME"
	ttl		= "300"
	records	= [aws_db_instance.db_primary[0].address]

	lifecycle {
		ignore_changes = [name]
	}
}

// Internal DNS for aurora-mysql primary database server, not create if db_count = 0
resource "aws_route53_record" "internal_aurora_db" {
	count	= var.db_engine == "aurora-mysql" && var.db_count > 0 ? 1 : 0

	zone_id	= data.aws_route53_zone.internal_zone.zone_id
	name	= "${var.prefix}-db.${var.internal_root_domain}"
	type	= "CNAME"
	ttl		= "300"
	records	= [aws_rds_cluster.db_cluster[0].endpoint]

	lifecycle {
		ignore_changes = [name]
	}
}

// Internal DNS for non-aurora-mysql replica database server, not create if db_count < 2
resource "aws_route53_record" "internal_db_replica" {
	count	= var.db_count > 1 && var.db_engine != "aurora-mysql" ? var.db_count - 1 : 0

	zone_id	= data.aws_route53_zone.internal_zone.zone_id
	name	= "${var.prefix}-db-${format("%02d", count.index + 1)}.${var.internal_root_domain}"
	type	= "CNAME"
	ttl		= "300"
	records	= [aws_db_instance.db_replica[count.index].address]

	lifecycle {
		ignore_changes = [name]
	}
}

// Internal DNS for aurora-mysql replica database server, not create if db_count < 2
resource "aws_route53_record" "internal_aurora_db_replica" {
	count	= var.db_count > 1 && var.db_engine == "aurora-mysql" ? 1 : 0

	zone_id	= data.aws_route53_zone.internal_zone.zone_id
	name	= "${var.prefix}-db-ro.${var.internal_root_domain}"
	type	= "CNAME"
	ttl		= "300"
	records	= [aws_rds_cluster.db_cluster[0].reader_endpoint]

	lifecycle {
		ignore_changes = [name]
	}
}

// Internal DNS for Redis server, not create if redis_count = 0
resource "aws_route53_record" "internal_redis" {
	count	= signum(var.redis_count)

	zone_id	= data.aws_route53_zone.internal_zone.zone_id
	name	= "${var.prefix}-redis.${var.internal_root_domain}"
	type	= "CNAME"
	ttl		= "300"
	records	= [aws_elasticache_replication_group.redis[count.index].primary_endpoint_address]

	lifecycle {
		ignore_changes = [name]
	}
}