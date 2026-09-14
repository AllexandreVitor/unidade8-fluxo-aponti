variable "aws_region" {
  description = "Região utilizada pelo ambiente LocalStack"
  type        = string
  default     = "us-east-1"
}

variable "bucket_name" {
  description = "Nome do bucket S3 da aplicação"
  type        = string
  default     = "agendamento-consultas-documentos"
}