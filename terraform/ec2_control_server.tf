# ec2_control_server.tf

resource "aws_instance" "control_server" {
  ami                         = var.control_server_ami
  instance_type               = var.instance_type_free_tier
  key_name                    = var.key_pair_name # {# BẮT BUỘC KHAI BÁO GIÁ TRỊ CHO BIẾN NÀY TRONG `variables.tf` HOẶC NHẬP KHI CHẠY #}
  subnet_id                   = aws_subnet.public.id

  # 5. Security Group IDs:
  #    Các nhóm bảo mật (tường lửa) sẽ được áp dụng cho instance này.
  #    Giá trị này được lấy từ tài nguyên "aws_security_group.control_server_sg" đã tạo trong `security_groups.tf`.
  vpc_security_group_ids      = [aws_security_group.control_server_sg.id]

  # 6. IAM Instance Profile:
  #    Gán một IAM Role cho instance này để nó có quyền tương tác với các dịch vụ AWS khác (nếu cần).
  #    Giá trị này được lấy từ tài nguyên "aws_iam_instance_profile.control_server_instance_profile" đã tạo trong `iam.tf`.
  iam_instance_profile        = aws_iam_instance_profile.control_server_instance_profile.name

  # 7. Cấu hình ổ đĩa gốc (Root Volume):
  root_block_device {
    volume_size           = 20    # Kích thước ổ đĩa là 20GB (nằm trong Free Tier của EBS nếu tổng cộng dưới 30GB)
    volume_type           = "gp3" # Loại ổ đĩa gp3 (hiệu năng tốt, thường vẫn trong Free Tier)
    delete_on_termination = true  # Tự động xóa ổ đĩa khi instance bị terminate
  }

  # 8. Tags (Nhãn):
  #    Gắn nhãn cho instance để dễ quản lý.
  tags = {
    Name        = "${var.project_name}-ControlServer" # Ví dụ: N8NAutomationDemo-ControlServer
    Project     = var.project_name                   # Ví dụ: N8NAutomationDemo
    Terraform   = "true"
    Role        = "Control-Jenkins-Nagios-n8n"
  }
}