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
  description = "Loại EC2 instance mặc định cho các server phụ (n8n, Nagios, NFS)."
  type        = string
  default     = "t2.micro"
}

// THÊM BIẾN MỚI CHO JENKINS SERVER INSTANCE TYPE
variable "jenkins_instance_type" {
  description = "Loại EC2 instance cho Jenkins Server. Khuyến nghị t3.small hoặc t3.medium."
  type        = string
  default     = "t3.small" // {# VÍ DỤ: Nâng cấp lên t3.small. Bạn có thể chọn t2.small, t3.medium, v.v. #}
}

// AMI ID cho Ubuntu Server gốc (ví dụ 22.04 LTS ở us-east-1)
// Bạn sẽ cài Docker trên các instance này sau.
variable "base_ubuntu_ami_id" {
  description = "AMI ID Ubuntu Server gốc cho các server chính."
  type        = string
  # {# BẮT BUỘC THAY THẾ: Bằng AMI ID Ubuntu Server 22.04 LTS (hoặc tương tự) ở vùng us-east-1 #}
  # {# Ví dụ: ami-053b0d53c279acc90 (CẦN KIỂM TRA LẠI TÍNH HỢP LỆ VÀ MỚI NHẤT) #}
  default = "ami-053b0d53c279acc90"
}

variable "n8n_server_ami" {
  description = "AMI ID for the n8n server. Should be your custom AMI with Docker pre-installed."
  type        = string
  // Replace with your actual custom Docker AMI ID, e.g., the same one used for Jenkins
  default     = "ami-0ebccc926f143695a" // EXAMPLE - UPDATE THIS!
}

variable "nagios_server_ami" {
  description = "AMI ID for the Nagios server. Should be your custom AMI with Docker pre-installed."
  type        = string
  // Replace with your actual custom Docker AMI ID, e.g., the same one used for Jenkins
  default     = "ami-0ebccc926f143695a" // EXAMPLE - UPDATE THIS!
}

variable "nfs_server_ami" {
  description = "AMI ID for the NFS server. Can be a base Ubuntu AMI or your custom Docker AMI."
  type        = string
  // Replace with a base Ubuntu AMI or your custom Docker AMI ID
  default     = "ami-053b0d53c279acc90" // EXAMPLE - UPDATE THIS (This is a generic Ubuntu 22.04 in us-east-1, check validity)
}

variable "key_pair_name" {
  description = "Tên của EC2 Key Pair ĐÃ TỒN TẠI trong vùng AWS đã chọn để truy cập SSH."
  type        = string
  default     = "nguyenp-key-pair" # {# BẮT BUỘC ĐIỀN TÊN KEY PAIR CỦA BẠN #}
}

variable "user_ip_for_ssh_override" {
  description = "GHI ĐÈ IP công cộng tự động phát hiện cho SSH. Nếu để trống, IP hiện tại của máy chạy Terraform sẽ được sử dụng. Nhập dưới dạng 'x.x.x.x/32'."
  type        = string
  default     = ""
}