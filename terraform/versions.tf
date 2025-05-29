# versions.tf

terraform {
  required_version = ">= 1.0" # Hoặc phiên bản Terraform bạn đang sử dụng

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0" # Luôn kiểm tra phiên bản AWS provider mới nhất và phù hợp
    }
  }

  # (TÙY CHỌN) Cấu hình S3 backend cho Terraform state
  # backend "s3" {
  #   bucket         = "{# KHAI BÁO: Tên S3 bucket của bạn, ví dụ: my-tfstate-bucket-us-east-1}"
  #   key            = "dev/infra-services/terraform.tfstate" # Đường dẫn lưu file state trong bucket
  #   region         = "us-east-1" # Vùng của S3 bucket (NÊN cùng vùng với tài nguyên)
  #   encrypt        = true
  #   # dynamodb_table = "{# KHAI BÁO: Tên DynamoDB table cho state locking (tùy chọn)}"
  # }
}