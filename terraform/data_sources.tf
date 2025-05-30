# data_sources.tf

data "http" "my_public_ip" {
  url = "https://checkip.amazonaws.com"
}

data "aws_availability_zones" "available" {
  # Không cần filter state, Terraform sẽ lấy các AZ có sẵn trong vùng đã chọn (var.aws_region)
}
test