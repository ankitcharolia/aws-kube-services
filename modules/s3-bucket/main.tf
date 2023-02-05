locals {
  s3_bucket_data = yamldecode(file("./etc/s3-buckets.yaml")) 
}

resource "aws_s3_bucket" "this" {
  for_each = { for bucket in local.s3_bucket_data.buckets : bucket.name => bucket }

  bucket  = each.value.name

  tags = {
    Name        = each.value.name
  }
}

# Bucket ACL
resource "aws_s3_bucket_acl" "this" {
  for_each = { for bucket in local.s3_bucket_data.buckets : bucket.name => bucket }

  bucket = each.value.name
  acl    = "private"
}

# Bucket Versioning
resource "aws_s3_bucket_versioning" "this" {
  for_each = { for bucket in local.s3_bucket_data.buckets : bucket.name => bucket }

  bucket = each.value.name

  versioning_configuration {
    status      = try(each.value.versioning ? "Enabled" : "Disabled", "Disabled")
  }
}

# Bucket logging
resource "aws_s3_bucket_logging" "this" {
  for_each = { for bucket in local.s3_bucket_data.buckets : bucket.name => bucket if bucket.logging }

  bucket = each.value.name
  target_bucket = each.value.name
  target_prefix = "log/"
}
