locals {
  s3_bucket_data = yamldecode(file("./etc/s3-buckets.yaml"))

    lifecycle_rules = flatten([for bucket in local.s3_bucket_data.buckets : [
      for rule in try(bucket.lifecycle_rules, []) : {
        name                      = bucket.name
        id                        = rule.id
        status                    = rule.status
        filter                        = try(rule.filter, null)
        transition                    = try(rule.transition, [])
        expiration                    = try(rule.expiration, null)
        noncurrent_version_transition = try(rule.noncurrent_version_transition, [])
        noncurrent_version_expiration = try(rule.noncurrent_version_expiration, null)
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
      status      = each.value.status

      dynamic "filter" {
        for_each = each.value.filter == null ? [] : [each.value.filter]
        content {
          and {
            prefix                    = try(filter.value.prefix, null)
            object_size_greater_than  = try(filter.value.object_size_greater_than, null)
            object_size_less_than     = try(filter.value.object_size_less_than, null)
          }
        }
      }
      # Max 1 block - expiration
      dynamic "expiration" {
        for_each = each.value.expiration == null ? [] : [each.value.expiration]
        content {
          date                         = try(expiration.value.date, null)
          days                         = try(expiration.value.days, null)
          expired_object_delete_marker = try(expiration.value.object_delete_marker, null)
        }
      }

      # Several blocks - transition
      dynamic "transition" {
        for_each = try(each.value.transition, [])
        content {
          date          = try(transition.value.date, null)
          days          = try(transition.value.days, null)
          storage_class = try(transition.value.storage_class, null)
        }
      }

      # Several blocks - noncurrent_version_transition
      dynamic "noncurrent_version_transition" {
        for_each = try(each.value.noncurrent_version_transition, [])
        content {
          noncurrent_days = try(noncurrent_version_transition.value.days, null)
          storage_class   = try(noncurrent_version_transition.value.storage_class, null)
        }
      }

      # Max 1 block - noncurrent_version_expiration
      dynamic "noncurrent_version_expiration" {
        for_each = each.value.noncurrent_version_expiration == null ? [] : [each.value.noncurrent_version_expiration]
        content {
          noncurrent_days = try(noncurrent_version_expiration.value.days, null)
        }
      }
  }
  depends_on = [aws_s3_bucket_versioning.this]
}

resource "aws_s3_bucket_policy" "allow_access_from_another_account" {
  for_each  = { for bucket in local.s3_bucket_data.buckets : bucket.name => bucket if try(bucket.bucket_policy != null, can(bucket.bucket_policy)) }


  bucket = each.value.name
  policy = file("./files/policies/${each.value.bucket_policy}")
}