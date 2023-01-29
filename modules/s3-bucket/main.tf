locals {
  s3_bucket_data = yamldecode(file("./etc/s3-buckets.yaml")) 
}

resource "aws_s3_bucket" "bucket" {
  for_each = { for bucket in local.s3_bucket_data.buckets : bucket.name => bucket }

  bucket = each.value.name

  tags = {
    Name        = each.value.name
  }
}