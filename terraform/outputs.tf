output "control_server_public_ip" {
  description = "Địa chỉ IP công cộng của Control Server."
  value       = aws_instance.control_server.public_ip
}

output "control_server_id" {
  description = "ID của Control Server EC2 instance."
  value       = aws_instance.control_server.id
}

output "nfs_server_public_ip" {
  description = "Địa chỉ IP công cộng của NFS Server."
  value       = aws_instance.nfs_server.public_ip
}

output "nfs_server_id" {
  description = "ID của NFS Server EC2 instance."
  value       = aws_instance.nfs_server.id
}

output "vpc_id" {
  description = "ID của VPC chính."
  value       = aws_vpc.main.id
}

output "public_subnet_id" {
  description = "ID của public subnet."
  value       = aws_subnet.public.id
}