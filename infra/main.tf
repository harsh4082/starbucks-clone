# Terraform - EKS Cluster

terraform {
  required_version = ">= 1.3.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1"   # ✅ Change to your AWS region
}


# VPC (using AWS VPC module)

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.5.1"

  name = "eks-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["ap-south-1a", "ap-south-1b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true

  tags = {
    Name = "eks-vpc"
  }
}


# EKS Cluster

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.8.4"

  cluster_name    = "starbucks-eks"
  cluster_version = "1.30"
  subnet_ids      = module.vpc.private_subnets
  vpc_id          = module.vpc.vpc_id

  # Control plane logging
  cluster_enabled_log_types = ["api", "audit", "authenticator"]

  eks_managed_node_groups = {
    default = {
      desired_size = 2
      max_size     = 3
      min_size     = 1

      instance_types = ["t3.medium"]
      capacity_type  = "ON_DEMAND"
    }
  }

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}


# Outputs

output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "cluster_certificate_authority" {
  value = module.eks.cluster_certificate_authority_data
}

output "node_group_role" {
  value = module.eks.eks_managed_node_groups.default.iam_role_name
}
