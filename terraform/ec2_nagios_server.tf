# ec2_nagios_server.tf

resource "aws_instance" "nagios_server" {
  ami                         = var.nagios_server_ami
  instance_type               = var.default_instance_type
  key_name                    = var.key_pair_name
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.nagios_server_sg.id] # SG mới
  iam_instance_profile        = aws_iam_instance_profile.nagios_server_instance_profile.name

  root_block_device {
    volume_size           = 15 # Có thể cần ít hơn Jenkins
    volume_type           = "gp3"
    delete_on_termination = true
  }

  tags = {
    Name        = "${var.project_name}-NagiosServer"
    Project     = var.project_name
    Terraform   = "true"
    Role        = "Nagios-Server"
  }
}