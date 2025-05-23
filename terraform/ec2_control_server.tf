resource "aws_instance" "control_server" {
  ami                         = var.control_server_ami
  instance_type               = var.instance_type_free_tier
  key_name                    = var.key_pair_name # {# KHAI BÁO: Tên key pair của bạn}
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.control_server_sg.id]
  iam_instance_profile        = aws_iam_instance_profile.control_server_instance_profile.name # Gán IAM Role

  # Đảm bảo root volume đủ dùng và nằm trong Free Tier
  root_block_device {
    volume_size = 20 # GB (Free Tier cho EBS lên đến 30GB)
    volume_type = "gp2" # Hoặc "gp3"
    delete_on_termination = true
  }

  tags = {
    Name        = "${var.project_name}-ControlServer"
    Project     = var.project_name
    Terraform   = "true"
    Role        = "Control-Jenkins-Nagios-n8n"
  }

  # (TÙY CHỌN) User data script để cài đặt các phần mềm cơ bản khi instance khởi động
  # user_data = <<-EOF
  #             #!/bin/bash
  #             sudo apt update -y
  #             sudo apt install -y git tree # Các gói cơ bản khác
  #             # Thêm lệnh cài đặt Jenkins, Nagios, n8n ở đây nếu muốn tự động hóa bước đầu
  #             EOF
}