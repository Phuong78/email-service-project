# versions.tf

terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # (TÙY CHỌN) Cấu hình S3 backend
  # backend "s3" {
  #   bucket         = "{# KHAI BÁO: Tên S3 bucket của bạn, ví dụ: my-tfstate-bucket-us-east-1}"
  #   key            = "dev/multi-server-demo/terraform.tfstate"
  #   region         = "us-east-1"
  #   encrypt        = true
  # }
}