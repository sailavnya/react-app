provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

resource "aws_s3_bucket" "react-s3bucket1203" {
  bucket = var.bucket_name

  website {
    index_document = "index.html"
    error_document = "index.html"
  }

  tags = {
    Name       = var.bucket_name
    Created_By = var.created_by
  }

}

resource "aws_s3_bucket_ownership_controls" "ownership_controls" {
  bucket = aws_s3_bucket.react-s3bucket1203.id
  rule {
    object_ownership = var.object_ownership
  }
}


resource "aws_s3_bucket_acl" "s3_bucket_acl" {
  depends_on = [aws_s3_bucket_ownership_controls.ownership_controls]
  bucket     = aws_s3_bucket.react-s3bucket1203.id
  acl        = "private"
}
resource "aws_cloudfront_origin_access_control" "cloudfront_oac" {
    name                              = "My_Cloudfront-OAC"
    description                       = "The origin access control configuration for the Cloudfront distribution"
    origin_access_control_origin_type = "s3"
    signing_behavior                  = "always"
    signing_protocol                  = "sigv4"
  }

  resource "aws_cloudfront_distribution" "website_cdn" {
    enabled = true

    origin {
      domain_name              = aws_s3_bucket.react-s3bucket1203.bucket_regional_domain_name
      origin_access_control_id = aws_cloudfront_origin_access_control.cloudfront_oac.id
      origin_id                = "origin-bucket-${aws_s3_bucket.react-s3bucket1203.id}"
    }

    default_root_object = "index.html"

    default_cache_behavior {
      allowed_methods        = ["GET", "HEAD", "DELETE", "OPTIONS", "PATCH", "POST", "PUT"]
      cached_methods         = ["GET", "HEAD"]
      min_ttl                = "0"
      default_ttl            = "300"
      max_ttl                = "1200"
      target_origin_id       = "origin-bucket-${aws_s3_bucket.react-s3bucket1203.id}"
      viewer_protocol_policy = "redirect-to-https"
      compress               = true

      forwarded_values {
        query_string = false
        cookies {
          forward = "none"
        }
      }
    }

    restrictions {
      geo_restriction {
        restriction_type = "none"
      }
    }

    custom_error_response {
      error_caching_min_ttl = 300
      error_code            = 404
      response_code         = "200"
      response_page_path    = "/404.html"
    }

    viewer_certificate {
      cloudfront_default_certificate = true
    }

    tags = {
      Created_By = var.created_by
    }
  }
resource "aws_s3_bucket_policy" "bucket_policy" {
      bucket = aws_s3_bucket.react-s3bucket1203.id
          policy = jsonencode({
            "Version" : "2012-10-17",
            "Statement" : [
              {
                "Sid" : "AllowCloudFrontServicePrincipalReadOnly",
                "Effect" : "Allow",
                "Principal" : {
                  "Service" : "cloudfront.amazonaws.com"
                },
                "Action" : "s3:GetObject",
                "Resource" : "${aws_s3_bucket.react-s3bucket1203.arn}/*",
                "Condition" : {
                  "StringEquals" : {
                    "AWS:SourceArn" : "${aws_cloudfront_distribution.website_cdn.arn}"
                  }
                }
              }
            ]
          })
        }
