// Get SSL certificate ARN from common name
data "aws_acm_certificate" "ssl" {
	count	= length(var.ssl_certificates)

	domain		= var.ssl_certificates[count.index]
	most_recent	= true
}