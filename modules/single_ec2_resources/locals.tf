locals {
	ami	= coalesce(var.ami, data.aws_ami.centos_ami.image_id)
}