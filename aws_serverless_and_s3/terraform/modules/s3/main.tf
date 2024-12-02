resource "aws_s3_bucket" "storage_bucket" {
  bucket = var.bucket_name
  force_destroy = false
  object_lock_enabled = false

  tags = {
    Name        = var.bucket_description
  }
}

resource "aws_s3_bucket_public_access_block" "no_public_access" {
  bucket = aws_s3_bucket.storage_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_cors_configuration" "cross_origin_rules" {
  bucket = aws_s3_bucket.storage_bucket.id

  # TODO
  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["PUT", "POST"]
    allowed_origins = ["https://s3-website-test.hashicorp.com"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }

  cors_rule {
    allowed_methods = ["GET"]
    allowed_origins = ["*"]
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "deletion_and_archival" {
  bucket = aws_s3_bucket.storage_bucket.id

  rule {
    id = "default-rule"
    filter {}

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
    status = "Enabled"
  }

  rule {
    id = "permanent-deletion-after-90-days"
    status = var.data_expiration ? "Enabled" : "Disabled"
    filter {}
    expiration {
      days = 90
    }
  }

  rule {
    id = "storage-class-transition"
    status = var.data_archival ? "Enabled" : "Disabled"
    filter {}

    transition {
      days          = 15
      storage_class = "STANDARD_IA"
    }
    transition {
      days          = 30
      storage_class = "GLACIER_IR"
    }
    transition {
      days          = 45
      storage_class = "GLACIER"
    }
  }

}