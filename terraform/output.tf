output "instance_public_ip" {
  value       = aws_eip.app_eip.public_ip
  description = "Public IP of the application server"
}