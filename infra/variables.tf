variable "region" {
  description = "AWS region"
  default     = "ap-south-1"
}

variable "cluster_name" {
  description = "EKS cluster name"
  default     = "starbucks-eks-cluster"
}

variable "node_desired_size" {
  default = 2   # increase to 2 or more
}

variable "node_max_size" {
  default = 3
}

variable "node_min_size" {
  default = 1
}

