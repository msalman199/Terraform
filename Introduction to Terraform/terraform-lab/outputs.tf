# Output values
output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.terraform_instance.id
}

output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.terraform_instance.public_ip
}

output "instance_public_dns" {
  description = "Public DNS name of the EC2 instance"
  value       = aws_instance.terraform_instance.public_dns
}

output "security_group_id" {
  description = "ID of the security group"
  value       = aws_security_group.terraform_sg.id
}

output "website_url" {
  description = "URL to access the web server"
  value       = "http://${aws_instance.terraform_instance.public_ip}"
}
