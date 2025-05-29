# variables.tf

variable "aws_region" {
  description = "Vùng AWS để triển khai tài nguyên."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Tên dự án, sử dụng để gắn thẻ tài nguyên."
  type        = string
  default     = "N8NAutomationDemo"
}

variable "vpc_cidr_block" {
  description = "Dải CIDR cho VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr_block" {
  description = "Dải CIDR cho public subnet."
  type        = string
  default     = "10.0.1.0/24"
}

variable "instance_type_free_tier" {
  description = "Loại EC2 instance phù hợp với Free Tier."
  type        = string
  default     = "t2.micro" 
}

variable "control_server_ami" {
  description = "AMI ID cho Control Server (Jenkins, Nagios, n8n) trong vùng us-east-1."
  type        = string
  default = "ami-053b0d53c279acc90" 
}

variable "nfs_server_ami" {
  description = "AMI ID cho NFS Server trong vùng us-east-1."
  type        = string
  default = "ami-053b0d53c279acc90" 
}

variable "key_pair_name" {
  description = "Tên của EC2 Key Pair ĐÃ TỒN TẠI trong vùng AWS us-east-1 để truy cập SSH."
  type        = string
  default     = "nguyenp-key-pair"
}

variable "user_ip_for_ssh_override" {
  description = "GHI ĐÈ IP công cộng tự động phát hiện cho SSH. Nếu để trống, IP hiện tại của máy chạy Terraform sẽ được sử dụng. Nhập dưới dạng 'x.x.x.x/32'."
  type        = string
  default     = "" # Để trống để ưu tiên IP tự động phát hiện
}