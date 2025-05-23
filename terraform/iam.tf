# IAM Role này cho phép EC2 instance (Control Server) có quyền tương tác với các dịch vụ AWS khác
# Ví dụ: Jenkins chạy trên Control Server có thể dùng Terraform để tạo EC2 cho khách hàng.

resource "aws_iam_role" "control_server_role" {
  name = "${var.project_name}-ControlServer-EC2-Role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name    = "${var.project_name}-ControlServer-Role"
    Project = var.project_name
  }
}

# Chính sách cho phép quản lý EC2, VPC, S3 (điều chỉnh quyền cụ thể nếu cần)
resource "aws_iam_role_policy_attachment" "ec2_full_access_for_control_server" {
  role       = aws_iam_role.control_server_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess" # Cân nhắc tạo policy tùy chỉnh với quyền hạn chế hơn
}

resource "aws_iam_role_policy_attachment" "vpc_full_access_for_control_server" {
  role       = aws_iam_role.control_server_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonVPCFullAccess" # Cân nhắc tạo policy tùy chỉnh
}

resource "aws_iam_role_policy_attachment" "s3_full_access_for_control_server" {
  role       = aws_iam_role.control_server_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess" # Cho phép quản lý S3 (ví dụ: Terraform state)
}


resource "aws_iam_instance_profile" "control_server_instance_profile" {
  name = "${var.project_name}-ControlServer-Instance-Profile"
  role = aws_iam_role.control_server_role.name

  tags = {
    Name    = "${var.project_name}-ControlServer-InstanceProfile"
    Project = var.project_name
  }
}