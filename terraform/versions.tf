terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0" // Luôn kiểm tra phiên bản provider mới nhất và phù hợp
    }
    http = { # Thêm http provider nếu chưa có, vì bạn dùng data "http"
      source = "hashicorp/http"
      version = "~> 3.0"
    }
  }

  # (TÙY CHỌN) Cấu hình S3 backend
  # backend "s3" {
  #   bucket         = "your-terraform-state-bucket-name" // THAY THẾ
  #   key            = "email-service-project/terraform.tfstate"
  #   region         = "us-east-1" // THAY THẾ bằng vùng của bucket
  #   encrypt        = true
  #   # dynamodb_table = "your-terraform-lock-table" // (Tùy chọn) THAY THẾ
  # }
}