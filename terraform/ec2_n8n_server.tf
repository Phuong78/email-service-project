# ec2_n8n_server.tf

resource "aws_instance" "n8n_server" {
  ami                         = var.n8n_server_ami
  instance_type               = var.default_instance_type
  key_name                    = var.key_pair_name
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.n8n_server_sg.id] # SG mới
  iam_instance_profile        = aws_iam_instance_profile.n8n_server_instance_profile.name

  root_block_device {
    volume_size           = 15 # Có thể cần ít hơn Jenkins
    volume_type           = "gp3"
    delete_on_termination = true
  }

  tags = {
    Name        = "${var.project_name}-n8nServer"
    Project     = var.project_name
    Terraform   = "true"
    Role        = "n8n-Server"
  }
}