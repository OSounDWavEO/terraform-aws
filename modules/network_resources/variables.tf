variable "aws_region" {
	type		= string
	description	= "AWS region for S3 endpoint"
	default		= "ap-southeast-1"
}

variable "prefix" {
	type		= string
	description	= "Resources' prefix"
}

variable "vpc_cidr" {
	type		= string
	description	= "IP range for dedicated VPC"
}

variable "az" {
	type		= list(string)
	description	= "list of AWS availability zones"
	default		= ["ap-southeast-1a", "ap-southeast-1b", "ap-southeast-1c"]
}

variable "tags" {
	type		= map(string)
	description	= "Resource's tags"
}