resource "aws_s3_bucket" "storage_bucket" {
  bucket = var.bucket_name
  force_destroy = false
  object_lock_enabled = false

  lifecycle {
    prevent_destroy = true
  }

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

  cors_rule {
    allowed_headers = ["content-type"]
    allowed_methods = ["POST"]
    allowed_origins = [var.fqdn]
    # Preflight request is an HTTP OPTIONS request sent by the browser to verify
    # if the server allows a cross-origin request before sending the actual request.
    max_age_seconds = 3000 # Cache preflight response for 3000 seconds
  }

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET"]
    allowed_origins = [var.fqdn]
    max_age_seconds = 3000 # Cache preflight response for 3000 seconds
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
    id = "permanent-deletion-after-180-days"
    status = var.data_expiration ? "Enabled" : "Disabled"
    filter {}
    expiration {
      days = 180
    }
  }

  rule {
    id = "storage-class-transition"
    status = var.data_archival ? "Enabled" : "Disabled"
    filter {}

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }
    transition {
      days          = 60
      storage_class = "GLACIER_IR"
    }
    transition {
      days          = 150
      storage_class = "GLACIER"
    }
  }

}