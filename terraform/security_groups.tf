locals {
  user_access_cidr = var.user_ip_for_ssh_override != "" ? var.user_ip_for_ssh_override : "${chomp(data.http.my_public_ip.response_body)}/32"
}

# --- Security Group cho Jenkins Server ---
resource "aws_security_group" "jenkins_server_sg" {
  name        = "${var.project_name}-JenkinsServer-SG"
  description = "Security group cho Jenkins Server"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH/Session Manager access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [local.user_access_cidr]
  }
  ingress {
    description = "Jenkins UI"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [local.user_access_cidr] # Hoặc ["0.0.0.0/0"] nếu có xác thực mạnh
  }
  ingress {
    description = "Jenkins Agent port"
    from_port   = 50000
    to_port     = 50000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "${var.project_name}-JenkinsServer-SG" }
}

# --- Security Group cho n8n Server ---
resource "aws_security_group" "n8n_server_sg" {
  name        = "${var.project_name}-n8nServer-SG"
  description = "Security group cho n8n Server"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH/Session Manager access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [local.user_access_cidr]
  }
  ingress {
    description = "n8n UI/Webhook port"
    from_port   = 5678
    to_port     = 5678
    protocol    = "tcp"
    # Cho phép từ mọi nơi để webhook có thể truy cập, n8n cần có cơ chế xác thực riêng
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "${var.project_name}-n8nServer-SG" }
}

# --- Security Group cho Nagios Server ---
resource "aws_security_group" "nagios_server_sg" {
  name        = "${var.project_name}-NagiosServer-SG"
  description = "Security group cho Nagios Server"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH/Session Manager access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [local.user_access_cidr]
  }
  ingress {
    description = "Nagios UI (HTTP on custom port 8081)" # Cổng mà user_data map cho Nagios
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = [local.user_access_cidr] # Hoặc ["0.0.0.0/0"] nếu có xác thực mạnh
  }
  ingress {
    description = "NRPE from monitored hosts (Customer VMs)"
    from_port   = 5666
    to_port     = 5666
    protocol    = "tcp"
    cidr_blocks = [aws_subnet.public.cidr_block] # Cho phép từ các máy trong cùng subnet
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "${var.project_name}-NagiosServer-SG" }
} # Đóng khối resource ở đây

# --- Security Group cho NFS Server ---
resource "aws_security_group" "nfs_server_sg" {
  name        = "${var.project_name}-NFS-Server-SG"
  description = "Security group cho NFS Server"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH/Session Manager access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [local.user_access_cidr]
  }
  ingress {
    description = "NFS from within VPC (TCP)"
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block] # Cho phép từ toàn bộ VPC
  }
  ingress {
    description = "NFS from within VPC (UDP)"
    from_port   = 2049
    to_port     = 2049
    protocol    = "udp"
    cidr_blocks = [var.vpc_cidr_block] # Cho phép từ toàn bộ VPC
  }
  # RPCBind/Portmapper (cần thiết cho một số phiên bản NFS client)
  ingress {
    description = "RPCBind/Portmapper from within VPC (TCP)"
    from_port   = 111
    to_port     = 111
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
  }
  ingress {
    description = "RPCBind/Portmapper from within VPC (UDP)"
    from_port   = 111
    to_port     = 111
    protocol    = "udp"
    cidr_blocks = [var.vpc_cidr_block]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "${var.project_name}-NFS-Server-SG" }
}