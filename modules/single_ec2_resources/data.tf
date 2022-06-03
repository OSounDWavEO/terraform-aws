data "aws_subnet" "subnet" {
	id	= var.subnet
}

data "aws_ami" "centos_ami" {
	most_recent	= true

	owners	= ["aws-marketplace"]

	filter {
		name	= "product-code"
		values	= ["aw0evgkw8e5c1q413zgy5pjce"]
	}
}

data "aws_route53_zone" "internal_zone" {
	name			= var.internal_root_domain
	private_zone	= true
}