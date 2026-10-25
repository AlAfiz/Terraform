output "Public_IP" {
  value = aws_instance.nginx_server.public_ip
}
