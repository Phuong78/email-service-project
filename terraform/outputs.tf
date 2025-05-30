# outputs.tf

output "vpc_id" {
  description = "ID của VPC chính."
  value       = aws_vpc.main.id
}

output "public_subnet_id" {
  description = "ID của public subnet."
  value       = aws_subnet.public.id
}

output "jenkins_server_public_ip" {
  description = "Địa chỉ IP công cộng của Jenkins Server."
  value       = aws_instance.jenkins_server.public_ip
}
output "jenkins_server_id" {
  description = "ID của Jenkins Server EC2 instance."
  value       = aws_instance.jenkins_server.id
}

output "n8n_server_public_ip" {
  description = "Địa chỉ IP công cộng của n8n Server."
  value       = aws_instance.n8n_server.public_ip
}
output "n8n_server_id" {
  description = "ID của n8n Server EC2 instance."
  value       = aws_instance.n8n_server.id
}

output "nagios_server_public_ip" {
  description = "Địa chỉ IP công cộng của Nagios Server."
  value       = aws_instance.nagios_server.public_ip
}
output "nagios_server_id" {
  description = "ID của Nagios Server EC2 instance."
  value       = aws_instance.nagios_server.id
}

output "nfs_server_public_ip" {
  description = "Địa chỉ IP công cộng của NFS Server."
  value       = aws_instance.nfs_server.public_ip
}
output "nfs_server_id" {
  description = "ID của NFS Server EC2 instance."
  value       = aws_instance.nfs_server.id
}