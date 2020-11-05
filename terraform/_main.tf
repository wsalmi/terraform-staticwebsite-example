terraform {
  required_version = ">= 0.12"
}

provider "aws" {
  version = "~> 3.0"
  profile = var.aws_profile
  region = var.aws_region
}

# Provider configuration
variable "aws_profile" { type = string }
variable "aws_region" { type = string }

# Read enviroment information
data "aws_caller_identity" "current" {}

# Random funny and useless
# All random providers -> https://registry.terraform.io/providers/hashicorp/random/latest/docs
resource "random_id" "sufix" { byte_length = 8 }
resource "random_pet" "pet" { }

# Find all files and yours metadata
# Module doc -> https://registry.terraform.io/modules/hashicorp/dir/template/latest 
module "template_files" {
  source = "hashicorp/dir/template"
  base_dir = "${path.module}/../www"
}

# Create bucket
# Bucket doc -> https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket
resource "aws_s3_bucket" "www" {
  bucket = "my-litle-bucket-${random_pet.pet.id}"
  force_destroy = "false"
  acl    = "public-read"
  website {
    index_document = "index.html"
    error_document = "index.html"
  }

  policy = <<POLICY
{
  "Version":"2012-10-17",
  "Statement":[
    {
      "Sid":"AddPerm",
      "Effect":"Allow",
      "Principal": "*",
      "Action":["s3:GetObject"],
      "Resource":["arn:aws:s3:::my-litle-bucket-${random_pet.pet.id}/*"]
    }
  ]
}
POLICY
}

# Upload all found files on "template_files" module
# Bucket object doc -> https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_object
resource "aws_s3_bucket_object" "static_files" {
  for_each = module.template_files.files

  bucket       = aws_s3_bucket.www.bucket
  key          = each.key
  content_type = each.value.content_type

  source  = each.value.source_path
  content = each.value.content

  etag = each.value.digests.md5
}

output "bucket-name" {
    value = aws_s3_bucket.www.bucket
}

output "bucket-website-endpoint" {
    value = aws_s3_bucket.www.website_endpoint
}