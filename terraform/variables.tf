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

variable "default_instance_type" {
  description = "Loại EC2 instance mặc định. Jenkins trên t2.micro có thể chậm."
  type        = string
  default     = "t2.micro"
}

variable "jenkins_server_ami" {
  # SỬA Ở ĐÂY: Xóa ${var.aws_region}
  description = "AMI ID cho Jenkins Server. (Bạn cần tìm AMI cho vùng đã chọn, ví dụ us-east-1)"
  type        = string
  default     = "ami-053b0d53c279acc90" # {# KHAI BÁO AMI cho us-east-1 #}
}

variable "n8n_server_ami" {
  # SỬA Ở ĐÂY: Xóa ${var.aws_region}
  description = "AMI ID cho n8n Server. (Bạn cần tìm AMI cho vùng đã chọn, ví dụ us-east-1)"
  type        = string
  default     = "ami-053b0d53c279acc90" # {# KHAI BÁO AMI cho us-east-1 #}
}

variable "nagios_server_ami" {
  # SỬA Ở ĐÂY: Xóa ${var.aws_region}
  description = "AMI ID cho Nagios Server. (Bạn cần tìm AMI cho vùng đã chọn, ví dụ us-east-1)"
  type        = string
  default     = "ami-053b0d53c279acc90" # {# KHAI BÁO AMI cho us-east-1 #}
}

variable "nfs_server_ami" {
  # SỬA Ở ĐÂY: Xóa ${var.aws_region}
  description = "AMI ID cho NFS Server. (Bạn cần tìm AMI cho vùng đã chọn, ví dụ us-east-1)"
  type        = string
  default     = "ami-053b0d53c279acc90" # {# KHAI BÁO AMI cho us-east-1 #}
}

variable "key_pair_name" {
  # SỬA Ở ĐÂY: Xóa ${var.aws_region}
  description = "Tên của EC2 Key Pair ĐÃ TỒN TẠI trong vùng AWS đã chọn để truy cập SSH."
  type        = string
  default     = "nguyenp-key-pair" # {# BẮT BUỘC KHAI BÁO TÊN KEY PAIR CỦA BẠN #}
}

variable "user_ip_for_ssh_override" {
  description = "GHI ĐÈ IP công cộng tự động phát hiện cho SSH. Nếu để trống, IP hiện tại của máy chạy Terraform sẽ được sử dụng. Nhập dưới dạng 'x.x.x.x/32'."
  type        = string
  default     = ""
}