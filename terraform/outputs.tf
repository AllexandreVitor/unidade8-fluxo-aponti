output "bucket_name" {
  description = "Nome do bucket S3 utilizado pela aplicação"
  value       = aws_s3_bucket.documentos.bucket
}