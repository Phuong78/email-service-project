resource "aws_security_group" "control_server_sg" {
  name        = "${var.project_name}-ControlServer-SG"
  description = "Security group cho Control Server (Jenkins, Nagios, n8n)"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH từ IP của bạn"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.user_ip_for_ssh] # {# KHAI BÁO: IP của bạn}
  }

  ingress {
    description = "HTTP cho Jenkins/Nagios/n8n UI"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Hoặc IP của bạn: [var.user_ip_for_ssh]
  }

  ingress {
    description = "HTTPS cho Jenkins/Nagios/n8n UI" # Nếu bạn cấu hình SSL
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Hoặc IP của bạn: [var.user_ip_for_ssh]
  }

  ingress {
    description = "Jenkins default port"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Hoặc IP của bạn: [var.user_ip_for_ssh]
  }

  ingress {
    description = "n8n default port"
    from_port   = 5678
    to_port     = 5678
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Hoặc IP của bạn: [var.user_ip_for_ssh]
  }
  
  # ingress {
  #   description = "Nagios NRPE từ Customer VMs (nếu dùng NRPE)"
  #   from_port   = 5666 
  #   to_port     = 5666
  #   protocol    = "tcp"
  #   source_security_group_id = aws_security_group.customer_vm_sg.id # Sẽ tạo sau nếu cần
  # }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # Allow all outbound
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-ControlServer-SG"
    Project     = var.project_name
    Terraform   = "true"
  }
}

resource "aws_security_group" "nfs_server_sg" {
  name        = "${var.project_name}-NFS-Server-SG"
  description = "Security group cho NFS Server"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH từ IP của bạn"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.user_ip_for_ssh] # {# KHAI BÁO: IP của bạn}
  }

  ingress {
    description = "NFS từ Customer VMs (TCP)"
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    # {# QUAN TRỌNG: Thay bằng source_security_group_id của Customer VMs sau khi tạo hoặc dải IP private của subnet customer}
    # source_security_group_id = aws_security_group.customer_vm_sg.id # Sẽ tạo sau nếu cần
    cidr_blocks = [aws_subnet.public.cidr_block] # Cho phép từ toàn bộ public subnet (cân nhắc thu hẹp)
  }

  ingress {
    description = "NFS từ Customer VMs (UDP)"
    from_port   = 2049
    to_port     = 2049
    protocol    = "udp"
    cidr_blocks = [aws_subnet.public.cidr_block] # Tương tự TCP
  }
  
  # Có thể cần thêm các port khác cho rpcbind (port 111) nếu cần
  # ingress {
  #   description = "RPCBind (portmapper) TCP"
  #   from_port   = 111
  #   to_port     = 111
  #   protocol    = "tcp"
  #   cidr_blocks = [aws_subnet.public.cidr_block]
  # }
  # ingress {
  #   description = "RPCBind (portmapper) UDP"
  #   from_port   = 111
  #   to_port     = 111
  #   protocol    = "udp"
  #   cidr_blocks = [aws_subnet.public.cidr_block]
  # }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-NFS-Server-SG"
    Project     = var.project_name
    Terraform   = "true"
  }
}

# Bạn sẽ cần một Security Group cho Customer VMs nữa, sẽ được tạo bởi Terraform khi onboarding khách hàng.
# Tạm thời, các rule cho NFS và Nagios ở trên có thể trỏ đến CIDR của subnet.