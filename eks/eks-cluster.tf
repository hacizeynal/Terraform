provider "kubernetes" {
  config_path = "~/.kube/config"
  host = data.aws_eks_cluster.my_app_eks_cluster.endpoint
  token = data.aws_eks_cluster_auth.my_app_eks_cluster.token
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.my_app_eks_cluster.certificate_authority.0.data)
}



data "aws_eks_cluster" "my_app_eks_cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "my_app_eks_cluster" {
  name = module.eks.cluster_id
}


module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "18.27.1"
  cluster_name    = "my-app-eks-cluster"
  cluster_version = "1.22"
  subnet_ids = module.my_app_vpc.private_subnets
  tags = {
    environment = "development"
    application = "my-app"
  }
  vpc_id = module.my_app_vpc.vpc_id
  create_aws_auth_configmap = true
  manage_aws_auth_configmap = true

  self_managed_node_group_defaults = {
    instance_type                          = "t2.large"
    update_launch_template_default_version = true
    iam_role_additional_policies = [
      "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    ]
  }

  self_managed_node_groups = {
    one = {
      name         = "worker-group-1"
      max_size     = 3
      desired_size = 2
      instance_type = "t2.small"
    },
    two = {
      name         = "worker-group-2"
      max_size     = 3
      desired_size = 1
      instance_type = "t2.medium"
    },
    three = {
      name         = "worker-group-3"
      max_size     = 3
      desired_size = 1
    }
  } 
}
