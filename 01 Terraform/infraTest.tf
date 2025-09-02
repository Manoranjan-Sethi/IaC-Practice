provider "aws" {
  region = "ap-south-1"
}

# VPC creation
resource "aws_vpc" "infra_vpc" {
  cidr_block = "10.0.0.0/16"
    tags = {
      Name = "MyProjectVpc"
    }
}

