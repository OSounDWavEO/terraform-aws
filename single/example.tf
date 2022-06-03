variable "key_pair" {
	type		= string
	description	= "Name of key pair"
}

module "example_single" {
	source	= "../modules/single_ec2_resources"

	subnet					= "example-subnet"
	prefix					= "dev-example"
	public_accessible		= true
	internal_root_domain	= "www.example.com"
	key_pair				= var.key_pair

	tags	= {
		Project		= "Example"
		Environment	= "Development"
	}
}