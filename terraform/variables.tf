variable "aws_region" {
  description = "Vùng AWS để triển khai tài nguyên."
  type        = string
  default     = "us-east-1" # {# KHAI BÁO: Chọn vùng AWS bạn muốn, ví dụ: ap-southeast-1, us-west-2}
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
  default     = "t2.micro" # {# KHAI BÁO: Kiểm tra loại instance Free Tier khả dụng trong vùng của bạn, ví dụ: t3.micro}
}

variable "control_server_ami" {
  description = "AMI ID cho Control Server (Jenkins, Nagios, n8n)."
  type        = string
  # {# KHAI BÁO: Tìm AMI ID phù hợp trong vùng của bạn. Ví dụ cho Ubuntu 22.04 LTS (Focal) ở us-east-1 (kiểm tra lại): ami-053b0d53c279acc90}
  # Bạn có thể tìm AMI ID trong AWS Management Console -> EC2 -> AMIs (chọn "Public images" và filter).
  # Hãy chọn một AMI "Free tier eligible".
  default = "ami-053b0d53c279acc90" # Ví dụ cho Ubuntu 22.04 ở us-east-1, thay thế nếu cần
}

variable "nfs_server_ami" {
  description = "AMI ID cho NFS Server."
  type        = string
  # {# KHAI BÁO: Tương tự như control_server_ami, chọn AMI phù hợp.}
  default = "ami-053b0d53c279acc90" # Ví dụ cho Ubuntu 22.04 ở us-east-1, thay thế nếu cần
}

variable "key_pair_name" {
  description = "Tên của EC2 Key Pair đã tồn tại trong vùng AWS của bạn để truy cập SSH vào instances."
  type        = string
  # {# KHAI BÁO: Tạo một Key Pair trong AWS EC2 Console và nhập tên vào đây, ví dụ: my-aws-keypair}
  # default     = "my-aws-keypair" # Bỏ comment và thay thế bằng tên key pair của bạn
}

variable "user_ip_for_ssh" {
  description = "Địa chỉ IP công cộng của bạn để cho phép truy cập SSH. Tìm IP của bạn tại https://checkip.amazonaws.com/"
  type        = string
  # {# KHAI BÁO: Nhập địa chỉ IP của bạn, ví dụ: "203.0.113.45/32"}
  # default     = "0.0.0.0/0" # CẢNH BÁO: KHÔNG AN TOÀN cho production. Chỉ dùng để test nhanh.
}