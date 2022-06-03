locals {
	// If ec2_ami is null or empty, use default image
	ec2_ami 	= coalesce(var.ec2_ami, data.aws_ami.centos_ami.image_id)

	// If ec2_security_groups is null or empty, use default security groups (internal, and load balancer)
	ec2_security_groups	= coalescelist(var.ec2_security_groups, [var.security_groups["internal"], var.security_groups["http_s_public_dmz"]])
}