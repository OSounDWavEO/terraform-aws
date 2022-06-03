// VPC - All subnets have 4 digits mask from VPC's CIDR block
resource "aws_vpc" "vpc" {
	cidr_block				= var.vpc_cidr
	enable_dns_hostnames	= true

	tags	= merge(var.tags, {
		Name	= "${var.prefix}-vpc"
	})
}

// Internet Gateway
resource "aws_internet_gateway" "igw" {
	vpc_id	= aws_vpc.vpc.id

	tags	= merge(var.tags, {
		Name	= "${var.prefix}-vpc-igw"
		Zone	= "Public"
	})
}

// Public DMZ subnets - 1 subnet per AZ, start from subnet number 0, maximum 4 subnets
resource "aws_subnet" "public_dmz" {
	count	= length(var.az) > 4 ? 4 : length(var.az)

	vpc_id				= aws_vpc.vpc.id
	cidr_block			= cidrsubnet(aws_vpc.vpc.cidr_block, 4, count.index)
	availability_zone	= element(var.az, count.index)

	tags	= merge(var.tags, {
		Name		= "${var.prefix}-vpc-public-dmz-${substr(element(var.az, count.index), -2, -1)}"
		Zone		= "Public ${format("%02d", count.index + 1)} - ${substr(element(var.az, count.index), -2, -1)}"
	})

	lifecycle {
		ignore_changes	= [cidr_block]
	}
}

// Private app subnets - 1 subnet per AZ, start from subnet number 4, maximum 4 subnets
resource "aws_subnet" "private_app" {
	count	= length(var.az) > 4 ? 4 : length(var.az)

	vpc_id				= aws_vpc.vpc.id
	cidr_block			= cidrsubnet(aws_vpc.vpc.cidr_block, 4, count.index + 4)
	availability_zone	= element(var.az, count.index)

	tags	= merge(var.tags, {
		Name		= "${var.prefix}-vpc-private-app-${substr(element(var.az, count.index), -2, -1)}"
		Zone		= "Private App ${format("%02d", count.index + 1)} - ${substr(element(var.az, count.index), -2, -1)}"
	})

	lifecycle {
		ignore_changes	= [cidr_block]
	}
}

// Private data subnets - 1 subnet per AZ, start from subnet number 8, maximum 4 subnets
resource "aws_subnet" "private_data" {
	count = length(var.az) > 4 ? 4 : length(var.az)

	vpc_id				= aws_vpc.vpc.id
	cidr_block			= cidrsubnet(aws_vpc.vpc.cidr_block, 4, count.index + 8)
	availability_zone	= element(var.az, count.index)

	tags	= merge(var.tags, {
		Name		= "${var.prefix}-vpc-private-data-${substr(element(var.az, count.index), -2, -1)}"
		Zone		= "Private Data ${format("%02d", count.index + 1)} - ${substr(element(var.az, count.index), -2, -1)}"
	})

	lifecycle {
		ignore_changes	= [cidr_block]
	}
}

// NAT gateway IP
resource "aws_eip" "ngw_eip" {
	vpc	= true

	tags	= merge(var.tags, {
		Name	= "${var.prefix}-vpc-ngw-ip"
		Zone	= "Public 01 - ${substr(var.az[0], -2, -1)}"
	})
}

// NAT gateway - place on first public DMZ subnet
resource "aws_nat_gateway" "ngw" {
	allocation_id	= aws_eip.ngw_eip.id
	subnet_id		= aws_subnet.public_dmz[0].id

	tags	= merge(var.tags, {
		Name	= "${var.prefix}-vpc-ngw"
		Zone	= "Public 01 - ${substr(var.az[0], -2, -1)}"
	})
}

// Network ACL - Allow all
resource "aws_default_network_acl" "acl" {
	default_network_acl_id	= aws_vpc.vpc.default_network_acl_id
	subnet_ids				= flatten([aws_subnet.public_dmz[*].id, aws_subnet.private_app[*].id, aws_subnet.private_data[*].id])

	ingress {
		protocol	= "-1"
		rule_no		= 999
		action		= "allow"
		cidr_block	= "0.0.0.0/0"
		from_port	= 0
		to_port		= 0
	}

	egress {
		protocol	= "-1"
		rule_no		= 999
		action		= "allow"
		cidr_block	= "0.0.0.0/0"
		from_port	= 0
		to_port		= 0
	}

	tags	= merge(var.tags, {
		Name	= "${var.prefix}-vpc-acl"
		Zone	= "Public 01 - ${substr(var.az[0], -2, -1)}"
	})

	lifecycle {
		ignore_changes	= [ingress, egress]
	}
}

// Route table for private app/data subnets (default route table)
resource "aws_default_route_table" "private_rtb" {
	default_route_table_id	= aws_vpc.vpc.main_route_table_id

	// Connect to the Internet via NAT gateway
	route {
		cidr_block		= "0.0.0.0/0"
		nat_gateway_id	= aws_nat_gateway.ngw.id
	}

	tags	= merge(var.tags, {
		Name	= "${var.prefix}-vpc-private-rtb"
		Zone	= "Private"
	})
}

// Route table for public DMZ subnets (default route table)
resource "aws_route_table" "public_rtb" {
	vpc_id	= aws_vpc.vpc.id

	// Connect to the Internet via Internet gateway
	route {
		cidr_block	= "0.0.0.0/0"
		gateway_id	= aws_internet_gateway.igw.id
	}

	tags	= merge(var.tags, {
		Name	= "${var.prefix}-vpc-public-rtb"
		Zone	= "Public"
	})
}

// Route table associate with public DMZ subnets
resource "aws_route_table_association" "public_dmz_rtb_assoc" {
	count	= length(var.az)

	subnet_id		= aws_subnet.public_dmz[count.index].id
	route_table_id	= aws_route_table.public_rtb.id
}

// S3 endpoint for this VPC
resource "aws_vpc_endpoint" "s3_endpoint" {
	vpc_id			= aws_vpc.vpc.id
	service_name	= "com.amazonaws.${var.aws_region}.s3"
	route_table_ids	= [aws_vpc.vpc.main_route_table_id, aws_route_table.public_rtb.id]
}