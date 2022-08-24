output "ec2_public_ip" {
    value = module.my-app-server.instance.public_ip
}