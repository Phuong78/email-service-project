provider "aws" {
  region = var.aws_region
}

resource "aws_security_group" "customer_vm_sg" {
  name        = "${var.customer_name}-vm-sg"
  description = "Security group cho máy chủ của khách hàng ${var.customer_name}"
  vpc_id      = data.aws_subnet.selected_subnet.vpc_id // Lấy VPC ID từ subnet

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] // CẨN THẬN: Mở SSH ra toàn thế giới. Nên giới hạn!
  }
  ingress {
    description = "SMTP"
    from_port   = 25
    to_port     = 25
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "SMTPS (Submission)"
    from_port   = 587 // Hoặc 465 nếu dùng SSL trực tiếp
    to_port     = 587
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "IMAPS"
    from_port   = 993
    to_port     = 993
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "POP3S"
    from_port   = 995
    to_port     = 995
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  // Thêm các port khác nếu cần (HTTP/HTTPS cho webmail, ...)

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "${var.customer_name}-vm-sg"
    Project = var.project_name_tag
  }
}

resource "aws_instance" "customer_vm" {
  ami                         = var.customer_vm_ami_id
  instance_type               = var.customer_vm_instance_type
  key_name                    = var.key_pair_name
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [aws_security_group.customer_vm_sg.id]
  // iam_instance_profile        = "your_customer_vm_iam_profile_name" // Tùy chọn: Nếu VM khách hàng cần quyền AWS

  tags = {
    Name     = "${var.customer_name}-MailServer"
    Project  = var.project_name_tag
    Customer = var.customer_name
  }
  // user_data = fileexists("user_data_customer.sh") ? file("user_data_customer.sh") : null 
  // Hoặc bạn có thể để Ansible làm toàn bộ việc cài đặt sau khi instance được tạo
}

data "aws_subnet" "selected_subnet" {
  id = var.subnet_id
}

output "customer_vm_public_ip" {
  description = "IP Public của máy chủ khách hàng"
  value       = aws_instance.customer_vm.public_ip
}

output "customer_vm_private_ip" {
  description = "IP Private của máy chủ khách hàng"
  value       = aws_instance.customer_vm.private_ip
}