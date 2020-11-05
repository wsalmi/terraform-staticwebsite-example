# Create a cloudfront distribution
# Cloudfront distribution doc -> https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution 
resource "aws_cloudfront_distribution" "www" {
  origin {
    custom_origin_config {
      http_port              = "80"
      https_port             = "443"
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    }

    domain_name = aws_s3_bucket.www.bucket_regional_domain_name
    origin_id   = aws_s3_bucket.www.bucket
  }
  wait_for_deployment = false
  enabled             = true
  comment             = "My CloudFront Example"
  default_root_object = "index.html"

  default_cache_behavior {
    viewer_protocol_policy = "redirect-to-https"
    compress               = false
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = aws_s3_bucket.www.bucket
    min_ttl                = 0
    default_ttl            = 0
    max_ttl                = 0

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  #aliases = ["foo.${data.aws_route53_zone.selected.name}"] # If you use a custom domain eg: foo.mydomain.com
  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true # If you use a custom domain, see this -> https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution#viewer-certificate-arguments 

    # Custom domain SSL
    #acm_certificate_arn = var.ssl_certificate
    #ssl_support_method  = "sni-only"
  }
}

output "cloudfront-endpoint" {
    value = aws_cloudfront_distribution.www.domain_name
}