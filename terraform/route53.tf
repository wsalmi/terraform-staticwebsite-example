# Route53 Zone data
/*
data "aws_route53_zone" "selected" {
  name         = "yourdomain.com.br"
  private_zone = false
}

resource "aws_route53_record" "www" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = "foo"
  type    = "A"
  
  alias {
    name                   = aws_cloudfront_distribution.www.domain_name
    zone_id                = aws_cloudfront_distribution.www.hosted_zone_id
    evaluate_target_health = false
  }
}
*/