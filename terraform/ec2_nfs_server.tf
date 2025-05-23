resource "aws_instance" "nfs_server" {
  ami                         = var.nfs_server_ami
  instance_type               = var.instance_type_free_tier
  key_name                    = var.key_pair_name # {# KHAI BÁO: Tên key pair của bạn}
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.nfs_server_sg.id]
  # Không cần IAM role phức tạp cho NFS server trong demo này

  root_block_device {
    volume_size = 10 # GB
    volume_type = "gp2"
    delete_on_termination = true
  }

  # (TÙY CHỌN) Có thể tạo thêm một EBS volume riêng cho NFS data
  # ebs_block_device {
  #   device_name = "/dev/sdf" # Hoặc /dev/xvdf
  #   volume_size = 20 # GB
  #   volume_type = "gp2"
  #   delete_on_termination = true
  # }

  tags = {
    Name        = "${var.project_name}-NFS-Server"
    Project     = var.project_name
    Terraform   = "true"
    Role        = "NFS-Server"
  }
}