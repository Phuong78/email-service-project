#terraform {
#  required_providers {
#    aws = {
#      source  = "hashicorp/aws"
#      version = "~> 5.0" # Kiểm tra phiên bản AWS provider mới nhất
#    }
#  }
  # (TÙY CHỌN) Cấu hình S3 backend cho Terraform state
  # backend "s3" {
  #   bucket         = "{# KHAI BÁO: Tên S3 bucket của bạn để lưu state, ví dụ: my-terraform-demo-state-bucket}"
  #   key            = "global/s3/terraform.tfstate"
  #   region         = "{# KHAI BÁO: Vùng AWS của S3 bucket, ví dụ: us-east-1}"
  #   encrypt        = true
  #   # dynamodb_table = "{# KHAI BÁO: Tên DynamoDB table cho state locking (tùy chọn)}" # Nên tạo DynamoDB table riêng cho locking
  # }
#}
# data_sources.tf (hoặc main.tf, providers.tf)

#data "http" "my_public_ip" {
#  url = "https://checkip.amazonaws.com"
#}

provider "aws" {
  region = var.aws_region
  # Không cần khai báo access_key và secret_key ở đây nếu bạn đã cấu hình AWS CLI
}