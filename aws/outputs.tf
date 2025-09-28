output "backend_instance_id" {
  value = aws_instance.backend.id
}

output "backend_instance_public_ip" {
  value = aws_instance.backend.public_ip
}
