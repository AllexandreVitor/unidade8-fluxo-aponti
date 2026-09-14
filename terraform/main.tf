terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  required_version = ">= 1.5.0"
}

provider "aws" {
  access_key                  = "test"
  secret_key                  = "test"
  region                      = var.aws_region
  s3_use_path_style           = true
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    s3  = "http://s3.localhost.localstack.cloud:4566"
    kms = "http://localhost:4566"
  }
}

resource "aws_s3_bucket" "documentos" {
  bucket = var.bucket_name
}

#CKV_AWS_18
resource "aws_s3_bucket" "logs" {
  bucket = "${var.bucket_name}-logs"
}

resource "aws_s3_bucket_logging" "documentos" {
  bucket = aws_s3_bucket.documentos.id

  target_bucket = aws_s3_bucket.logs.id
  target_prefix = "access-logs/"
}

# CKV2_AWS_6 do checkov
resource "aws_s3_bucket_public_access_block" "documentos" {
  bucket = aws_s3_bucket.documentos.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

#CKV_AWS_21
resource "aws_s3_bucket_versioning" "documentos" {
  bucket = aws_s3_bucket.documentos.id

  versioning_configuration {
    status = "Enabled"
  }
}

#CKV2_AWS_61
resource "aws_s3_bucket_lifecycle_configuration" "documentos" {
  bucket = aws_s3_bucket.documentos.id

  rule {
    id     = "gerenciamento-documentos"
    status = "Enabled"

    filter {
      prefix = ""
    }

    expiration {
      expired_object_delete_marker = true
    }

    # CKV_AWS_300
    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}


#CKV_AWS_145
resource "aws_kms_key" "documentos" {
  description             = "Chave KMS para criptografia dos documentos do sistema de agendamento"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid    = "AllowAccountAdministration"
        Effect = "Allow"

        Principal = {
          AWS = "arn:aws:iam::000000000000:root"
        }

        Action   = "kms:*"
        Resource = "*"
      }
    ]
  })
}

resource "aws_s3_bucket_server_side_encryption_configuration" "documentos" {
  bucket = aws_s3_bucket.documentos.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.documentos.arn
    }
  }
}