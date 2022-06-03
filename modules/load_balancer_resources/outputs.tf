output dns {
	value	= aws_lb.alb.dns_name
}

output zone_id {
	value	= aws_lb.alb.zone_id
}