variable "az" {
	type		= list(string)
	description	= "list of AWS availability zones"
	default		= [
		"ap-southeast-1a",
		"ap-southeast-1b",
		"ap-southeast-1c"
	]
}

variable "subnet" {
	type		= string
	description	= "Subnet for placing server"
}

variable "prefix" {
	type		= string
	description	= "EC2 instance prefix"
}

variable "tags" {
	type		= map(string)
	description	= "Resource's tags"
}

variable "ami" {
	type		= string
	description	= "Amazon Linux AMI for all EC2 instances. Default is latest CentOS 7"
	default		= ""
}

variable "size" {
	type		= string
	description	= "Size of application admin instance"
	default		= "t3.medium"
}

variable "storage" {
	type		= string
	description	= "Storage of application admin instance's disk"
	default		= 50
}

variable "security_groups" {
	type		= list(string)
	description	= "Security groups for application EC2 instance. Default is internal"
	default		= []
}

variable "admin_role" {
	type		= bool
	description	= "True if this ec2 instance serve as admin (backend) server"
	default		= true
}

variable "app_role" {
	type		= bool
	description	= "True if this ec2 instance serve as application (frontend) server"
	default		= true
}

variable "app_number" {
	type		= number
	description	= "Number of application server if app_role set to True"
	default		= 1
}

variable "public_accessible" {
	type		= bool
	description	= "Attach AWS Elastic IP to this server"
	default		= false
}

variable "internal_root_domain" {
	type		= string
	description	= "Internal Route53 root domain name"
}

variable "key_pair" {
	type		= string
	description	= "Name of key pair"
}