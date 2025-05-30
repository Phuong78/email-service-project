variable "aws_region" {
  description = "Vùng AWS"
  type        = string
}

variable "customer_name" {
  description = "Tên định danh cho khách hàng (dùng cho tags, tên máy chủ)"
  type        = string
}

variable "customer_vm_ami_id" {
  description = "AMI ID cho máy chủ của khách hàng (nên là AMI có sẵn Postfix, Dovecot cơ bản, hoặc Ubuntu gốc rồi Ansible cài)"
  type        = string
  // Ví dụ: bạn có thể dùng lại var.base_ubuntu_ami_id từ Terraform chính
  // Hoặc tạo một AMI chuyên dụng cho mail server
}

variable "customer_vm_instance_type" {
  description = "Loại instance cho máy chủ khách hàng"
  type        = string
  default     = "t2.micro" // Hoặc loại instance phù hợp
}

variable "key_pair_name" {
  description = "Tên Key Pair cho máy chủ khách hàng"
  type        = string
}

variable "subnet_id" {
  description = "ID của Subnet để triển khai máy chủ khách hàng"
  type        = string
}

variable "project_name_tag" {
  description = "Giá trị cho tag Project"
  type        = string
}