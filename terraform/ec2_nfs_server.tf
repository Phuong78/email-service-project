# ec2_nfs_server.tf

resource "aws_instance" "nfs_server" {
  # 1. AMI (Amazon Machine Image) ID:
  #    Tương tự như Control Server, giá trị này được lấy từ biến "nfs_server_ami"
  #    mà bạn đã khai báo (và CẦN CẬP NHẬT) trong file `variables.tf`.
  #    Ví dụ trong `variables.tf` bạn có:
  #    variable "nfs_server_ami" {
  #      default = "ami-053b0d53c279acc90" # AMI cho Ubuntu 22.04 ở us-east-1 (BẠN CẦN KIỂM TRA VÀ CẬP NHẬT)
  #    }
  #    Bạn có thể dùng chung AMI với Control Server nếu HĐH và cấu hình ban đầu là như nhau.
  ami                         = var.nfs_server_ami

  # 2. Loại Instance:
  #    Lấy từ biến "instance_type_free_tier" trong `variables.tf`.
  instance_type               = var.instance_type_free_tier

  # 3. Key Pair Name:
  #    Lấy từ biến "key_pair_name" trong `variables.tf`. Đảm bảo đây là Key Pair
  #    đã tồn tại ở vùng us-east-1.
  key_name                    = var.key_pair_name # {# BẮT BUỘC KHAI BÁO GIÁ TRỊ CHO BIẾN NÀY TRONG `variables.tf` HOẶC NHẬP KHI CHẠY #}

  # 4. Subnet ID:
  #    Lấy từ tài nguyên "aws_subnet.public" đã tạo trong `vpc.tf`.
  subnet_id                   = aws_subnet.public.id

  # 5. Security Group IDs:
  #    Lấy từ tài nguyên "aws_security_group.nfs_server_sg" đã tạo trong `security_groups.tf`.
  vpc_security_group_ids      = [aws_security_group.nfs_server_sg.id]

  # 6. Cấu hình ổ đĩa gốc (Root Volume):
  root_block_device {
    volume_size           = 10    # Kích thước ổ đĩa là 10GB (nhỏ hơn cho NFS server nếu không lưu nhiều dữ liệu trên root)
    volume_type           = "gp3"
    delete_on_termination = true
  }

  # 7. Tags (Nhãn):
  tags = {
    Name        = "${var.project_name}-NFS-Server" # Ví dụ: N8NAutomationDemo-NFS-Server
    Project     = var.project_name
    Terraform   = "true"
    Role        = "NFS-Server"
  }
}