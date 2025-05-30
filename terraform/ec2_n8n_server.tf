resource "aws_instance" "n8n_server" {
  ami                         = var.base_ubuntu_ami_id // Sử dụng AMI gốc
  instance_type               = var.default_instance_type
  key_name                    = var.key_pair_name
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.n8n_server_sg.id]
  iam_instance_profile        = aws_iam_instance_profile.n8n_server_instance_profile.name

  root_block_device {
    volume_size           = 15
    volume_type           = "gp3"
    delete_on_termination = true
  }

  user_data = <<-EOF
              #!/bin/bash
              sudo apt update -y
              # Cài đặt Docker
              sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
              curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
              sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
              sudo apt update -y
              sudo apt install -y docker-ce
              sudo systemctl enable docker
              sudo systemctl start docker
              sudo usermod -aG docker ubuntu

              # Cài đặt n8n qua Docker
              sudo docker volume create n8n_data
              sudo docker run -d \
                --name n8n-server-container \
                -p 5678:5678 \
                -v n8n_data:/home/node/.n8n \
                --restart=on-failure \
                n8nio/n8n
              EOF

  tags = {
    Name        = "${var.project_name}-n8nServer"
    Project     = var.project_name
    Terraform   = "true"
    Role        = "n8n-Server"
  }
}