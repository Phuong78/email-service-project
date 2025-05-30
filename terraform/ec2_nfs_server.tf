resource "aws_instance" "nfs_server" {
  ami                         = var.base_ubuntu_ami_id // Sử dụng AMI gốc
  instance_type               = var.default_instance_type
  key_name                    = var.key_pair_name
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.nfs_server_sg.id]
  iam_instance_profile        = aws_iam_instance_profile.nfs_server_instance_profile.name

  root_block_device {
    volume_size           = 10
    volume_type           = "gp3"
    delete_on_termination = true
  }

  user_data = <<-EOF
              #!/bin/bash
              sudo apt update -y
              # Cài đặt NFS Kernel Server
              sudo apt install -y nfs-kernel-server

              # Tạo thư mục chia sẻ
              sudo mkdir -p /srv/nfs/shared_mail_data
              sudo chown nobody:nogroup /srv/nfs/shared_mail_data
              sudo chmod 777 /srv/nfs/shared_mail_data # Cân nhắc quyền chặt chẽ hơn

              # Cấu hình file /etc/exports
              # Thay 10.0.1.0/24 bằng dải IP của public subnet hoặc các client cần truy cập
              echo "/srv/nfs/shared_mail_data    ${var.public_subnet_cidr_block}(rw,sync,no_subtree_check,no_root_squash)" | sudo tee /etc/exports

              # Export thư mục chia sẻ và khởi động lại dịch vụ
              sudo exportfs -a
              sudo systemctl restart nfs-kernel-server
              sudo systemctl enable nfs-kernel-server
              EOF

  tags = {
    Name        = "${var.project_name}-NFS-Server"
    Project     = var.project_name
    Terraform   = "true"
    Role        = "NFS-Server"
  }
}