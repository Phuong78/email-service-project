# security_groups.tf

locals {
  # Sử dụng IP tự động phát hiện hoặc override cho SSH và có thể cho các UI
  # Nếu muốn các UI (Jenkins, n8n, Nagios) mở ra 0.0.0.0/0, hãy thay thế logic này bằng ["0.0.0.0/0"]
  # cho các rule ingress tương ứng (CẨN THẬN VỀ BẢO MẬT).
  # Để truy cập qua Session Manager, các rule SSH này có thể không cần thiết.
  user_access_cidr = var.user_ip_for_ssh_override != "" ? var.user_ip_for_ssh_override : "${chomp(data.http.my_public_ip.response_body)}/32"
}

# --- Security Group cho Jenkins Server ---
resource "aws_security_group" "jenkins_server_sg" { # Đổi tên từ control_server_sg
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
    cidr_blocks = ["0.0.0.0/0"] # Cho phép agent kết nối từ bất kỳ đâu trong VPC hoặc ngoài (tùy cấu hình agent)
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
    cidr_blocks = [local.user_access_cidr] # Hoặc ["0.0.0.0/0"] nếu n8n có xác thực và bạn muốn webhook public
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
    description = "Nagios UI (HTTP)"
    from_port   = 80 # Hoặc port bạn dùng cho Nagios UI, ví dụ 8081
    to_port     = 80 # Hoặc port bạn dùng cho Nagios UI, ví dụ 8081
    protocol    = "tcp"
    cidr_blocks = [local.user_access_cidr] # Hoặc ["0.0.0.0/0"] nếu có xác thực mạnh
  }
  ingress {
    description = "NRPE from monitored hosts (Customer VMs)"
    from_port   = 5666
    to_port     = 5666
    protocol    = "tcp"
    cidr_blocks = [aws_subnet.public.cidr_block] # Tạm thời, sau này có thể là SG của Customer VMs
    # Hoặc source_security_group_id = var.customer_vm_sg_id (nếu bạn tạo SG riêng cho customer VMs)
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] # Nagios cần ra internet để gửi thông báo (ví dụ qua n8n webhook)
  }
  tags = { Name = "${var.project_name}-NagiosServer-SG" }

# Trong resource "aws_security_group" "nagios_server_sg"

ingress {
  description = "Nagios UI (HTTP on custom port)"
  from_port   = 8081 # Port bạn đang map cho Nagios UI
  to_port     = 8081 # Port bạn đang map cho Nagios UI
  protocol    = "tcp"
  cidr_blocks = [local.user_access_cidr] # Sử dụng IP động của bạn đã định nghĩa
}

# Các rule ingress khác (SSH, NRPE) giữ nguyên
ingress {
  description = "SSH/Session Manager access"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = [local.user_access_cidr]
}
ingress {
  description = "NRPE from monitored hosts (Customer VMs)"
  from_port   = 5666
  to_port     = 5666
  protocol    = "tcp"
  cidr_blocks = [aws_subnet.public.cidr_block]
}

# Rule HTTP port 80 hiện tại có thể không cần thiết nếu UI Nagios chỉ chạy trên 8081
# ingress {
#   description = "Nagios UI (HTTP)" # Rule này đang cho phép port 80
#   from_port   = 80
#   to_port     = 80
#   protocol    = "tcp"
#   cidr_blocks = [local.user_access_cidr]
# }

}

# --- Security Group cho NFS Server (Giữ nguyên, chỉ đảm bảo SSH dùng local.user_access_cidr) ---
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
    description = "NFS from Customer VMs/Other Servers (TCP)"
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = [aws_subnet.public.cidr_block]
  }
  ingress {
    description = "NFS from Customer VMs/Other Servers (UDP)"
    from_port   = 2049
    to_port     = 2049
    protocol    = "udp"
    cidr_blocks = [aws_subnet.public.cidr_block]
  }
  # ... (rpcbind rules nếu cần) ...
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "${var.project_name}-NFS-Server-SG" }
}