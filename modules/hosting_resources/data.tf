data "aws_ami" "centos_ami" {
	most_recent	= true

	owners	= ["aws-marketplace"]

	filter {
		name	= "product-code"
		values	= ["aw0evgkw8e5c1q413zgy5pjce"]
	}
}

data "aws_subnet" "public_dmz" {
	count	= length(var.subnets["public_dmz"])

	id	= var.subnets["public_dmz"][count.index]
}

data "aws_subnet" "private_app" {
	count	= length(var.subnets["private_app"])

	id	= var.subnets["private_app"][count.index]
}

data "aws_subnet" "private_data" {
	count	= length(var.subnets["private_data"])

	id	= var.subnets["private_data"][count.index]
}

data "aws_route53_zone" "internal_zone" {
	name			= "${var.internal_root_domain}."
	private_zone	= true
}