output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.nodejs_server.id
}

output "public_ip" {
  description = "AWS assigned public IPv4 address"
  value       = aws_instance.nodejs_server.public_ip
}

output "public_dns" {
  description = "EC2 public DNS"
  value       = aws_instance.nodejs_server.public_dns
}

output "application_url" {
  description = "Node.js application URL"
  value       = "http://${aws_instance.nodejs_server.public_ip}:3000"
}

output "health_check_url" {
  description = "Node.js health check URL"
  value       = "http://${aws_instance.nodejs_server.public_ip}:3000/health"
}