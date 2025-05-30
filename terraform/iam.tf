# iam.tf

resource "aws_iam_role" "jenkins_server_role" {
  name = "${var.project_name}-JenkinsServer-EC2-Role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action    = "sts:AssumeRole",
      Effect    = "Allow",
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
  tags = { Name = "${var.project_name}-JenkinsServer-Role" }
}

resource "aws_iam_role_policy_attachment" "jenkins_ssm_core" {
  role       = aws_iam_role.jenkins_server_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# QUAN TRỌNG: Jenkins cần các quyền này để quản lý tài nguyên AWS (tạo VM khách hàng)
resource "aws_iam_role_policy_attachment" "jenkins_ec2_full_access" {
  role       = aws_iam_role.jenkins_server_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

resource "aws_iam_role_policy_attachment" "jenkins_vpc_full_access" {
  role       = aws_iam_role.jenkins_server_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonVPCFullAccess" # Nếu Jenkins tạo VPC/subnet cho khách hàng
}

resource "aws_iam_role_policy_attachment" "jenkins_s3_access" { # Nếu Jenkins cần truy cập S3 (lưu state, artifacts)
  role       = aws_iam_role.jenkins_server_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess" # Cân nhắc giới hạn quyền S3 hơn
}

#resource "aws_iam_role_policy_attachment" "jenkins_iam_pass_role_access" { # Nếu Jenkins cần gán IAM role cho các instance nó tạo
#  role = aws_iam_role.jenkins_server_role.name
#  policy_arn = "arn:aws:iam::aws:policy/IAMPassRole" # Cho phép pass role, có thể cần thêm quyền tạo role/policy nếu Jenkins tự tạo
#}


resource "aws_iam_instance_profile" "jenkins_server_instance_profile" {
  name = "${var.project_name}-JenkinsServer-Instance-Profile"
  role = aws_iam_role.jenkins_server_role.name
  tags = { Name = "${var.project_name}-JenkinsServer-InstanceProfile" }
}

# --- IAM cho n8n Server ---
resource "aws_iam_role" "n8n_server_role" {
  name = "${var.project_name}-n8nServer-EC2-Role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action    = "sts:AssumeRole",
      Effect    = "Allow",
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
  tags = { Name = "${var.project_name}-n8nServer-Role" }
}

resource "aws_iam_role_policy_attachment" "n8n_ssm_core" {
  role       = aws_iam_role.n8n_server_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
# {# CÂN NHẮC: Nếu n8n workflows cần tương tác với dịch vụ AWS (S3, SES,...), thêm policy tương ứng ở đây #}

resource "aws_iam_instance_profile" "n8n_server_instance_profile" {
  name = "${var.project_name}-n8nServer-Instance-Profile"
  role = aws_iam_role.n8n_server_role.name
  tags = { Name = "${var.project_name}-n8nServer-InstanceProfile" }
}

# --- IAM cho Nagios Server ---
resource "aws_iam_role" "nagios_server_role" {
  name = "${var.project_name}-NagiosServer-EC2-Role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action    = "sts:AssumeRole",
      Effect    = "Allow",
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
  tags = { Name = "${var.project_name}-NagiosServer-Role" }
}

resource "aws_iam_role_policy_attachment" "nagios_ssm_core" {
  role       = aws_iam_role.nagios_server_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
# {# CÂN NHẮC: Nagios thường không cần nhiều quyền AWS, trừ khi ghi log/metric ra CloudWatch/S3 #}

resource "aws_iam_instance_profile" "nagios_server_instance_profile" {
  name = "${var.project_name}-NagiosServer-Instance-Profile"
  role = aws_iam_role.nagios_server_role.name
  tags = { Name = "${var.project_name}-NagiosServer-InstanceProfile" }
}

# --- IAM cho NFS Server (Để truy cập qua Session Manager) ---
resource "aws_iam_role" "nfs_server_role" {
  name = "${var.project_name}-NFS-Server-EC2-Role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action    = "sts:AssumeRole",
      Effect    = "Allow",
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
  tags = { Name = "${var.project_name}-NFS-Server-Role" }
}

resource "aws_iam_role_policy_attachment" "nfs_ssm_core" {
  role       = aws_iam_role.nfs_server_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "nfs_server_instance_profile" {
  name = "${var.project_name}-NFS-Server-Instance-Profile"
  role = aws_iam_role.nfs_server_role.name
  tags = { Name = "${var.project_name}-NFS-Server-InstanceProfile" }
}