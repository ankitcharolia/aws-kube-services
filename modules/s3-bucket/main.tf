locals {
  s3_bucket_data = yamldecode(file("./etc/s3-buckets.yaml"))

    lifecycle_rules = flatten([for bucket in local.s3_bucket_data.buckets : [
      for rule in try(bucket.lifecycle_rules, []) : {
        name            = bucket.name
        id              = rule.id
        status          = rule.status
        expiration_date = try(rule.expiration.date, null)
        expiration_days = try(rule.expiration.days, null)
        prefix                    = try(rule.prefix, null)
        object_size_greater_than  = try(rule.object_size_greater_than, null)
        object_size_less_than     = try(rule.object_size_less_than, null)
        expiration_object_delete_marker     = try(rule.expiration.object_delete_marker, null)
        noncurrent_version_expiration_days  = try(rule.noncurrent_version_expiration_days, null)
        transition_date = try(rule.transition.date, null)
        transition_days = try(rule.transition.days, null)
        noncurrent_version_transition_days = try(rule.noncurrent_version_transition.days, null)
        noncurrent_version_transition_storage_class = try(rule.noncurrent_version_transition.storage_class, null)
        transition_storage_class = try(rule.transition.storage_class, null)
        }
      ]
  ]) 
}

resource "aws_s3_bucket" "this" {
  for_each  = { for bucket in local.s3_bucket_data.buckets : bucket.name => bucket }

  bucket    = each.value.name

  tags = {
    Name        = each.value.name
  }
}

# Bucket ACL
resource "aws_s3_bucket_acl" "this" {
  for_each  = { for bucket in local.s3_bucket_data.buckets : bucket.name => bucket }

  bucket    = each.value.name
  acl       = "private"
}

# Bucket Versioning
resource "aws_s3_bucket_versioning" "this" {
  for_each  = { for bucket in local.s3_bucket_data.buckets : bucket.name => bucket }

  bucket    = each.value.name

  versioning_configuration {
    status      = try(each.value.versioning ? "Enabled" : "Disabled", "Disabled")
  }
}

# Bucket logging
resource "aws_s3_bucket_logging" "this" {
  for_each = { for bucket in local.s3_bucket_data.buckets : bucket.name => bucket if try(bucket.logging, false) }

  bucket        = each.value.name
  target_bucket = each.value.name
  target_prefix = "log/"
}

# Bucket Object Lock Configuration
resource "aws_s3_bucket_object_lock_configuration" "this" {
  for_each  = { for bucket in local.s3_bucket_data.buckets : bucket.name => bucket if try(bucket.object_lock, false) }

  bucket    = each.value.name

  rule {
    default_retention {
      mode  = each.value.object_lock.mode
      days  = each.value.object_lock.days
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "this" {
  for_each =  { for idx, record in local.lifecycle_rules : idx => record }

  bucket    = each.value.name

  rule {
      id          = try(each.value.id, null)
      prefix      = try(each.value.prefix, null)
      status      = each.value.status

      filter {
        and {
          prefix                    = try(each.value.prefix, null)
          object_size_greater_than  = try(each.value.object_size_greater_than, null)
          object_size_less_than     = try(each.value.object_size_less_than, null)
        }
      }
      # Max 1 block - expiration
      expiration {
          date                         = try(each.value.expiration_date, null)
          days                         = try(each.value.expiration_days, null)
          expired_object_delete_marker = try(each.value.expiration_object_delete_marker, null)
      }

      # Several blocks - transition, this terraform module is supporting only one block
      transition {
          date          = try(each.value.transition_date, null)
          days          = try(each.value.transition_days, null)
          storage_class = try(each.value.transition_storage_class, null)
      }

      # Max 1 block - noncurrent_version_expiration
      noncurrent_version_expiration {
          noncurrent_days = try(each.value.noncurrent_version_expiration_days, null)
      }

      # Several blocks - noncurrent_version_transition, this terraform module is supporting only one block
      noncurrent_version_transition {
          noncurrent_days = try(each.value.noncurrent_version_transition_days, null)
          storage_class   = try(each.value.noncurrent_version_transition_storage_class, null)
      }
  }
  depends_on = [aws_s3_bucket_versioning.this]
}

resource "aws_s3_bucket_policy" "allow_access_from_another_account" {
  for_each  = { for bucket in local.s3_bucket_data.buckets : bucket.name => bucket if try(bucket.bucket_policy != null, can(bucket.bucket_policy)) }


  bucket = each.value.name
  policy = file("./files/policies/${each.value.bucket_policy}")
}