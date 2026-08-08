# 1. Fetch available AZs in the current region
data "aws_availability_zones" "available" {
  state = "available"
}

# 2. Main VPC Configuration
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "Three-Tier-VPC"
  }
}

# 3. Internet Gateway for Public Internet Traffic
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "Three-Tier-NAT"
  }
}