variable "vpc" {
	type		= string
	description	= "VPC ID"
}

variable "prefix" {
	type		= string
	description	= "Resources' prefix"
}

variable "az" {
	type		= list(string)
	description	= "list of AWS availability zones"
	default		= [
		"ap-southeast-1a",
		"ap-southeast-1b",
		"ap-southeast-1c"
	]
}

variable "subnets" {
	type		= map(list(string))
	description	= "List of subnets in VPC"
}

variable "security_groups" {
	type		= map(string)
	description	= "List of security group created in the VPC"
}

variable "ec2_ami" {
	type		= string
	description	= "Amazon Linux AMI for all EC2 instances. Default is latest CentOS 7"
	default		= null
}

variable "ec2_placement_group" {
	type		= string
	description	= "AWS placement group for provisioning EC2 instances together in each availability zones"
	default 	= null
}

variable "ec2_security_groups" {
	type		= list(string)
	description	= "Security groups attached to all EC2 instances"
	default		= []
}

variable "ec2_app_count" {
	type		= number
	description	= "Number of application EC2 instance provisioned"
	default		= 2
}

variable "ec2_app_size" {
	type		= string
	description	= "Size of application EC2 instance"
	default		= "c5.2xlarge"
}

variable "ec2_app_storage" {
	type		= number
	description	= "Storage of application EC2 instance's disk"
	default		= 100
}

variable "separate_admin" {
	type		= bool
	description	= "True for provision dedicated admin server"
	default		= true
}

variable "ec2_admin_az" {
	type		= string
	description	= "Availability zone to host admin server"
	default		= "ap-southeast-1a"
}

variable "ec2_admin_size" {
	type		= string
	description	= "Size of admin EC2 instance"
	default		= "m5.large"
}

variable "ec2_admin_storage" {
	type		= number
	description	= "Storage of admin EC2 instance's disk"
	default		= 100
}

variable "separate_nfs" {
	type		= bool
	description	= "True for provision dedicated NFS server"
	default		= true
}

variable "ec2_nfs_az" {
	type		= string
	description	= "Availability zone to host NFS server"
	default		= ""
}

variable "ec2_nfs_size" {
	type		= string
	description	= "Size of NFS EC2 instance"
	default		= "t3.medium"
}

variable "ec2_nfs_storage" {
	type		= number
	description	= "Storage of NFS EC2 instance's disk"
	default		= 200
}

variable "db_engine" {
	type		= string
	description	= "Engine of database"
	default		= "mysql"
}

variable "db_engine_version" {
	type		= string
	description	= "Engine version of database"
	default		= "5.7"
}

variable "db_multi_az" {
	type		= string
	description	= "Enable multi-AZ"
	default		= true
}

variable "db_parameter" {
	type		= string
	description	= "Parameter group of database"
	default		= "default.mysql5.7"
}

variable "db_count" {
	type		= string
	description	= "Number of database"
	default		= 1
}

variable "db_primary_size" {
	type		= string
	description	= "Size of primary RDS instance"
	default		= "db.m5.xlarge"
}

variable "db_replica_size" {
	type		= string
	description	= "Size of replica RDS instance"
	default		= "db.m5.xlarge"
}

variable "db_storage" {
	type		= number
	description	= "Storage RDS instance in GB"
	default		= 300
}

variable "db_master_username" {
	type		= string
	description	= "RDS master username"
	default		= "master"
}

variable "redis_count" {
	type		= number
	description	= "Number of ElastiCache's shards provisioned"
	default		= 1
}

variable "redis_engine_version" {
	type		= string
	description	= "Engine version of Redis"
	default		= "5.0"
}

variable "redis_parameter" {
	type		= string
	description	= "Parameter group of Redis"
	default		= "default.redis5.0"
}

variable "redis_size" {
	type		= string
	description	= "Size of Redis"
	default		= "cache.m5.large"
}

variable "internal_root_domain" {
	type		= string
	description	= "Internal Route53 root domain name"
}

variable "key_pair" {
	type		= string
	description	= "Name of key pair"
}

variable "tags" {
	type		= map(string)
	description	= "Resource's tags"
}