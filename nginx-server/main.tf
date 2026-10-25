module "my_nginx_server" {
  source = "./modules/ec2-nginx"


  aws_region    = var.aws_region
  instance_type = var.instance_type
  cidr_block    = var.cidr_block
}

output "Public_IP" {
  value = module.my_nginx_server.Public_IP
}
