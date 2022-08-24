
variable "vpc_cidr_block" {}
variable "private_subnets" {}
variable "public_subnets" {}


data "aws_availability_zones" "azs" {}

module "my_app_vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "my_app_vpc"
  cidr = var.vpc_cidr_block

  azs = data.aws_availability_zones.azs.names
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  enable_nat_gateway = true
  single_nat_gateway = true
  enable_dns_hostnames =true

  tags = {
    "kubernetes.io/cluster/my-app-eks-cluster" = "shared"
  }
  private_subnet_tags ={
    "kubernetes.io/cluster/my-app-eks-cluster" = "shared"
    "kubernetes.io/role/internal-elb" = 1
  }
  public_subnet_tags = {
    "kubernetes.io/cluster/my-app-eks-cluster" = "shared"
    "kubernetes.io/role/elb" = 1
  }
}
