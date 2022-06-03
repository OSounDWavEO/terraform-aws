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
	description	= "List of AWS availability zones"
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
	description	= "Amazon Linux AMI for all EC2 instances. Default is latest CentOS"
}

variable "ec2_placement_group" {
	type		= string
	description	= "AWS placement group for provisioning EC2 instances together in each availability zones"
}

variable "ec2_security_groups" {
	type		= list(string)
	description	= "Security groups attached to all EC2 instances"
}

variable "ec2_app_count" {
	type		= number
	description	= "Number of application EC2 instance provisioned"
}

variable "ec2_app_size" {
	type		= string
	description	= "Size of application EC2 instance"
}

variable "ec2_app_storage" {
	type		= number
	description	= "Storage of application EC2 instance's disk"
}

variable "separated_admin" {
	type		= bool
	description	= "True for provision dedicated admin server"
}

variable "ec2_admin_az" {
	type		= string
	description	= "Availability zone to host admin server"
}

variable "ec2_admin_size" {
	type		= string
	description	= "Size of admin EC2 instance"
}

variable "ec2_admin_storage" {
	type		= number
	description	= "Storage of admin EC2 instance's disk"
}

variable "separated_nfs" {
	type		= bool
	description	= "True for provision NFS server"
}

variable "ec2_nfs_az" {
	type		= string
	description	= "Availability zone to host NFS server"
}

variable "ec2_nfs_size" {
	type		= string
	description	= "Size of NFS EC2 instance"
}

variable "ec2_nfs_storage" {
	type		= number
	description	= "Storage of media NFS instance's disk"
}

variable "db_engine" {
	type		= string
	description	= "Engine of database"
}

variable "db_engine_version" {
	type		= string
	description	= "Engine version of database"
}

variable "db_multi_az" {
	type		= bool
	description	= "Enable multi-AZ"
}

variable "db_parameter" {
	type		= string
	description	= "Parameter group of database"
}

variable "db_count" {
	type		= number
	description	= "Number of database replica"
}

variable "db_primary_size" {
	type		= string
	description	= "Size of primary RDS instance"
}

variable "db_replica_size" {
	type		= string
	description	= "Size of replica RDS instance"
}

variable "db_storage" {
	type		= number
	description	= "Storage RDS instance in GB"
}

variable "db_master_username" {
	type		= string
	description = "RDS master username"
}

variable "redis_count" {
	type		= number
	description	= "Number of ElastiCache's shards provisioned"
}

variable "redis_engine_version" {
	type		= string
	description	= "Engine version of Redis"
}

variable "redis_parameter" {
	type		= string
	description	= "Parameter group of Redis"
}

variable "redis_size" {
	type		= string
	description	= "Size of Redis"
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