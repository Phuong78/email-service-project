resource "aws_instance" "jenkins_server" {
  ami                         = var.base_ubuntu_ami_id
  instance_type               = var.jenkins_instance_type
  key_name                    = var.key_pair_name
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.jenkins_server_sg.id]
  iam_instance_profile        = aws_iam_instance_profile.jenkins_server_instance_profile.name

  root_block_device {
    volume_size           = 30
    volume_type           = "gp3"
    delete_on_termination = true
  }

  user_data = <<-EOF
              #!/bin/bash
              sudo apt update -y
              # Cài đặt Java (Jenkins cần Java)
              sudo apt install -y openjdk-17-jre # Hoặc openjdk-11-jre tùy phiên bản Jenkins
              # Cài đặt Docker
              sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
              curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
              sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $$(lsb_release -cs) stable" # SỬA Ở ĐÂY
              sudo apt update -y
              sudo apt install -y docker-ce
              sudo systemctl enable docker
              sudo systemctl start docker
              sudo usermod -aG docker ubuntu

              # Cài đặt Jenkins (qua Docker)
              sudo docker volume create jenkins_home
              sudo docker run -d \
                -p 8080:8080 \
                -p 50000:50000 \
                -v jenkins_home:/var/jenkins_home \
                -v /var/run/docker.sock:/var/run/docker.sock \
                --name jenkins-server-container \
                --restart=on-failure \
                jenkins/jenkins:lts-jdk17

              # (Tùy chọn) Cài đặt Terraform CLI
              sudo apt install -y wget unzip
              TERRAFORM_VERSION="1.8.3" # Kiểm tra phiên bản mới nhất
              # SỬA Ở ĐÂY: sử dụng $$ để escape $ cho biến shell
              wget https://releases.hashicorp.com/terraform/$${TERRAFORM_VERSION}/terraform_$${TERRAFORM_VERSION}_linux_amd64.zip
              unzip terraform_$${TERRAFORM_VERSION}_linux_amd64.zip
              sudo mv terraform /usr/local/bin/
              rm terraform_$${TERRAFORM_VERSION}_linux_amd64.zip

              # (Tùy chọn) Cài đặt Ansible
              sudo apt install -y ansible
              EOF

  tags = {
    Name        = "${var.project_name}-JenkinsServer"
    Project     = var.project_name
    Terraform   = "true"
    Role        = "Jenkins-Server"
  }
}