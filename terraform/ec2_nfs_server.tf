# ec2_nfs_server.tf

resource "aws_instance" "nfs_server" {
  ami                         = var.nfs_server_ami
  instance_type               = var.default_instance_type # NFS thường không cần nhiều CPU/RAM
  key_name                    = var.key_pair_name
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.nfs_server_sg.id]
  iam_instance_profile        = aws_iam_instance_profile.nfs_server_instance_profile.name # CẬP NHẬT

  root_block_device {
    volume_size           = 10
    volume_type           = "gp3"
    delete_on_termination = true
  }

  tags = {
    Name        = "${var.project_name}-NFS-Server"
    Project     = var.project_name
    Terraform   = "true"
    Role        = "NFS-Server"
  }
}