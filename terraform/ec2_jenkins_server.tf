# ec2_jenkins_server.tf

resource "aws_instance" "jenkins_server" {
  ami                         = var.base_ubuntu_ami_id
  instance_type               = var.jenkins_instance_type # SỬ DỤNG BIẾN MỚI CHO JENKINS
  key_name                    = var.key_pair_name
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.jenkins_server_sg.id]
  iam_instance_profile        = aws_iam_instance_profile.jenkins_server_instance_profile.name

  root_block_device {
    volume_size           = 30 # Tăng dung lượng ổ đĩa cho Jenkins
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