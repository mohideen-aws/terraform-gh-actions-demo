# Require TF version to be same as or greater than 0.12.13
terraform {
  required_version = ">=0.12.13"
  backend "s3" {
    bucket         = "meratests3bucketskeval-128907654678"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "aws-locks0-meratests3bucketskeval"
    encrypt        = true
  }
}

# Download any stable version in AWS provider of 2.36.0 or higher in 2.36 train
provider "aws" {
  region  = "us-east-1"
  version = "~> 2.36.0"
}


# Commented out until after bootstrap

/*
# Call the seed_module to build our ADO seed info
module "bootstrap" {
  source                      = "./modules/bootstrap"
  name_of_s3_bucket           = "meratests3bucketskeval-128907654678"
  dynamo_db_table_name        = "aws-locks0-meratests3bucketskeval"
  iam_user_name               = "GitHubActionsIamUser"
  ado_iam_role_name           = "GitHubActionsIamRole"
  aws_iam_policy_permits_name = "GitHubActionsIamPolicyPermits"
  aws_iam_policy_assume_name  = "GitHubActionsIamPolicyAssume"
}
*/ 


# Build the VPC
resource "aws_vpc" "vpc" {
  cidr_block           = "10.1.0.0/16"
  instance_tenancy     = "default"

  tags = {
    Name      = "Vpc"
    Terraform = "true"
  }
}
  
/*  
# Build the VPC2
resource "aws_vpc" "vpc2" {
  cidr_block           = "10.2.0.0/16"
  instance_tenancy     = "default"

  tags = {
    Name      = "Vpc2"
    Terraform = "true"
  }
}
*/

# Build route table 1
resource "aws_route_table" "route_table1" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "RouteTable1"
    Terraform = "true"
  }
}

# Build route table 2
resource "aws_route_table" "route_table2" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "RouteTable2"
    Terraform = "true"
  }
}
 
 #Build Subnet in VPC1
resource "aws_subnet" "my_subnet" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.1.10.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "VPC1-Subnet"
  }
}
/*  
#Build Instance Windows in VPC1
  resource "aws_instance" "web" {
  ami           = "ami-033594f8862b03bb2"
  instance_type = "t2.micro"
  availability_zone = "us-east-1a"

  tags = {
    Name = "HelloWorld"
  }
}

 */   
#Build Instance Linux in VPC1
  resource "aws_instance" "weblinux" {
  ami           = "ami-0022f774911c1d690"
  instance_type = "t2.micro"
  availability_zone = "us-east-1a"
  tags = {
    Name = "HelloWorld"
  }
}

