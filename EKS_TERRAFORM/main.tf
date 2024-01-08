# VPC Module
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.0.0"

  name = "prod-vpc"
  cidr = "192.168.0.0/16"

  azs            = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets = ["192.168.1.0/24", "192.168.2.0/24", "192.168.3.0/24"]
  public_subnets  = ["192.168.4.0/24", "192.168.5.0/24", "192.168.6.0/24"]

  enable_nat_gateway = true

  # Security Group for allowing all traffic
  ingress_cidr_blocks = ["0.0.0.0/0"]
}

# EKS Cluster
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.0.4"

  cluster_name    = "eks-cluster"
  cluster_version = "1.23"

  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.public_subnets

  enable_irsa = true

  eks_managed_node_groups = {
    green = {
      min_size         = 2
      max_size         = 2
      desired_size     = 2
      instance_types   = ["t2.medium"]
      key_name          = "your-key-pair-name"
      additional_security_group_ids = [module.vpc.security_group_id]
    }
  }
}
