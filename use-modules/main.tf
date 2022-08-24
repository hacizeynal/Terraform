provider "aws" {
  # No need to add since we have added all configuration including region,access_key and secret_access_key via aws configure list command 
  # it is located at ~/.aws/credentials
}

resource "aws_vpc" "my_app_vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    "Name" = "${var.env_prefix}-vpc"
  }
}

module "my_app_subnet" {
  source = "./modules/subnet"
  subnet_cidr_block = var.subnet_cidr_block
  availibility_zone = var.availibility_zone
  env_prefix = var.env_prefix
  vpc_id = aws_vpc.my_app_vpc.id
  default_route_table_id = aws_vpc.my_app_vpc.default_route_table_id
}

module "my-app-server" {
  source = "./modules/webserver"
  vpc_id = aws_vpc.my_app_vpc.id
  my_source_ip = var.my_source_ip
  env_prefix = var.env_prefix
  image_name = var.image_name
  my_public_key_location = var.my_public_key_location
  availibility_zone =var.availibility_zone
  instance_type =var.instance_type
  subnet_id = module.my_app_subnet.subnet.id

}

  

