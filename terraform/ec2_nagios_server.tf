resource "aws_instance" "nagios_server" {
  ami                         = var.base_ubuntu_ami_id // Sử dụng AMI gốc
  instance_type               = var.default_instance_type
  key_name                    = var.key_pair_name
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.nagios_server_sg.id]
  iam_instance_profile        = aws_iam_instance_profile.nagios_server_instance_profile.name

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

              # Chuẩn bị thư mục cấu hình cho Nagios trên host
              # User 'ubuntu' (UID 1000) sẽ chạy script này, Docker container thường chạy với user khác
              # Tạo thư mục và cấp quyền để Docker container có thể ghi vào
              mkdir -p /home/ubuntu/nagios-docker/etc
              mkdir -p /home/ubuntu/nagios-docker/var
              mkdir -p /home/ubuntu/nagios-docker/custom-plugins
              sudo chown -R 1000:1000 /home/ubuntu/nagios-docker # Cấp quyền cho user ubuntu

              # Cài đặt Nagios qua Docker (ví dụ image jasonrivers/nagios)
              # Port 8081 là ví dụ, đảm bảo SG cho phép cổng này
              sudo docker run -d \
                --name nagios-server-container \
                -p 8081:80 \
                -v /home/ubuntu/nagios-docker/etc/:/opt/nagios/etc/ \
                -v /home/ubuntu/nagios-docker/var/:/opt/nagios/var/ \
                -v /home/ubuntu/nagios-docker/custom-plugins/:/opt/nagios/libexec/custom-plugins \
                --restart=on-failure \
                jasonrivers/nagios:latest
              EOF

  tags = {
    Name        = "${var.project_name}-NagiosServer"
    Project     = var.project_name
    Terraform   = "true"
    Role        = "Nagios-Server"
  }
}