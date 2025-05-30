# ec2_jenkins_server.tf

resource "aws_instance" "jenkins_server" { # Đổi tên resource
  ami                         = var.jenkins_server_ami
  instance_type               = var.default_instance_type # Hoặc một biến instance_type riêng cho Jenkins
  key_name                    = var.key_pair_name
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.jenkins_server_sg.id] # Sẽ đổi tên SG
  iam_instance_profile        = aws_iam_instance_profile.jenkins_server_instance_profile.name

  root_block_device {
    volume_size           = 20
    volume_type           = "gp3"
    delete_on_termination = true
  }

  tags = {
    Name        = "${var.project_name}-JenkinsServer"
    Project     = var.project_name
    Terraform   = "true"
    Role        = "Jenkins-Server"
  }
}