provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
}

data "aws_availability_zones" "available" {}

locals {
  name = "eks-cluster"
  region = "us-east-1"

  #cluster_name = "eks-cluster-${random_string.suffix.result}"

  vpc_cidr = "10.0.0.0/16"
  azs = ["us-east-1a", "us-east-1b", "us-east-1c"]

  private_subnets    = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets     = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
    
}
#resource "random_string" "suffix" {
#  length  = 8
#  special = false
#}