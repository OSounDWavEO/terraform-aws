resource "aws_default_security_group" "internal" {
	vpc_id = aws_vpc.vpc.id

	ingress {
		from_port	= 0
		to_port		= 0
		protocol	= "-1"
		self		= true
		description	= "Allow all from the same security group"
	}

	egress {
		from_port	= 0
		to_port		= 0
		protocol	= "-1"
		cidr_blocks	= ["0.0.0.0/0"]
		description	= "Allow all to all"
	}

	tags	= merge(var.tags, {
		Name	= "${var.prefix}-internal-sg"
	})
}

resource "aws_security_group" "http_s_public_dmz" {
	name		= "HTTP/S - public DMZ subnets"
	description	= "Allow HTTP/S from public DMZ subnets"
	vpc_id		= aws_vpc.vpc.id

	ingress {
		from_port	= 80
		to_port		= 80
		protocol	= "tcp"
		cidr_blocks	= aws_subnet.public_dmz[*].cidr_block
		description	= "Allow HTTP from public DMZ subnets"
	}

	ingress {
		from_port	= 443
		to_port		= 443
		protocol	= "tcp"
		cidr_blocks	= aws_subnet.public_dmz[*].cidr_block
		description	= "Allow HTTPS from public DMZ subnets"
	}

	egress {
		from_port	= 0
		to_port		= 0
		protocol	= "-1"
		cidr_blocks	= ["0.0.0.0/0"]
		description	= "Allow all to all"
	}

	tags	= merge(var.tags, {
		Name	= "${var.prefix}-http-s-public-dmz-sg"
	})

	lifecycle {
		create_before_destroy	= true
	}
}

resource "aws_security_group" "http_s_all" {
	name		= "HTTP/S - all"
	description	= "Allow HTTP/S from all"
	vpc_id		= aws_vpc.vpc.id

	ingress {
		from_port	= 80
		to_port		= 80
		protocol	= "tcp"
		cidr_blocks	= ["0.0.0.0/0"]
		description	= "Allow HTTP from all"
	}

	ingress {
		from_port	= 443
		to_port		= 443
		protocol	= "tcp"
		cidr_blocks	= ["0.0.0.0/0"]
		description	= "Allow HTTPS from all"
	}

	egress {
		from_port	= 0
		to_port		= 0
		protocol	= "-1"
		cidr_blocks	= ["0.0.0.0/0"]
		description	= "Allow all to all"
	}

	tags	= merge(var.tags, {
		Name	= "${var.prefix}-http-s-all-sg"
	})

	lifecycle {
		create_before_destroy	= true
	}
}

resource "aws_security_group" "mysql_private_app_subnets" {
	name		= "MySQL - private app subnets"
	description	= "Allow MySQL from private app subnets"
	vpc_id		= aws_vpc.vpc.id

	ingress {
		from_port	= 3306
		to_port		= 3306
		protocol	= "tcp"
		cidr_blocks	= aws_subnet.private_app[*].cidr_block
		description	= "Allow MySQL from private app subnets"
	}

	tags	= merge(var.tags, {
		Name	= "${var.prefix}-mysql-private-app-sg"
	})

	lifecycle {
		create_before_destroy	= true
	}
}

resource "aws_security_group" "redis_private_app_subnets" {
	name		= "Redis - private app subnets"
	description	= "Allow Redis from private app subnets"
	vpc_id		= aws_vpc.vpc.id

	ingress {
		from_port	= 6379
		to_port		= 6380
		protocol	= "tcp"
		cidr_blocks	= aws_subnet.private_app[*].cidr_block
		description	= "Allow Redis from private app subnets"
	}

	tags	= merge(var.tags, {
		Name	= "${var.prefix}-redis-private-app-sg"
	})

	lifecycle {
		create_before_destroy	= true
	}
}