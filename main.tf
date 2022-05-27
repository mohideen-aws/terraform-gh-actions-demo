# Require TF version to be same as or greater than 0.12.13
terraform {
  required_version = ">=0.12.13"
  backend "s3" {
    bucket         = "mohi-terraform-demo-bucket"
    key            = "terraform.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "aws-locks"
    encrypt        = true
  }
}

# Download any stable version in AWS provider of 2.36.0 or higher in 2.36 train
provider "aws" {
  region  = "eu-west-1"
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
  availability_zone = "eu-west-1a"

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

   
#Build Instance Linux in VPC1
  resource "aws_instance" "ec2-linux" {
  ami           = "ami-0c321db7d6db74d19"
  instance_type = "t2.micro"
  availability_zone = "eu-west-1a"
  tags = {
    Name = "linux-terraform-demo"
  }
}
*/
#AMI Filter for Windows Server 2019 Base

data "aws_ami" "windows" {
    most_recent = true

    filter {
        name   = "name"
        values = ["Windows_Server-2019-English-Full-Base-*"]

    }

    filter {
       name   = "virtualization-type"
       values = ["hvm"]
    }

    owners = ["801119661308"] # Canonical

}

data "template_file" "windows-userdata" {
  template = <<EOF
<powershell>
# Rename Machine
Rename-Computer -NewName "mytestserver" -Force;
# Install IIS
Install-WindowsFeature -name Web-Server -IncludeManagementTools;
# Restart machine
shutdown -r -t 10;
</powershell>
EOF
}

# # Create EC2 Instance
# resource "aws_instance" "windows-server" {
#   ami                         = data.aws_ami.windows-2019.id
#   instance_type               = var.windows_instance_type
#   subnet_id                   = aws_subnet.public-subnet.id
#   vpc_security_group_ids      = [aws_security_group.aws-windows-sg.id]
#   associate_public_ip_address = var.windows_associate_public_ip_address
#   source_dest_check           = false
#   key_name                    = aws_key_pair.key_pair.key_name
#   user_data                   = data.template_file.windows-userdata.rendered
#AWS Instance

resource "aws_instance" "example" {
     ami = data.aws_ami.windows.id
     instance_type = "t2.micro"
     availability_zone = var.availability_zone
     user_data = data.template_file.windows-userdata.rendered
     key_name = "mykey"

lifecycle {
     ignore_changes = [ami]
     }
}

resource "aws_cloudwatch_metric_alarm" "ec2_cpu" {
     alarm_name               = "cpu-utilization"
     comparison_operator       = "GreaterThanOrEqualToThreshold"
     evaluation_periods       = "2"
     metric_name               = "CPUUtilization"
     namespace                 = "AWS/EC2"
     period                   = "120" #seconds
     statistic                 = "Average"
     threshold                 = "80"
   alarm_description         = "This metric monitors ec2 cpu utilization"
     insufficient_data_actions = []

dimensions = {

       InstanceId = aws_instance.example.id

     }

}

variable "availability_zone" {
     type = string
     default = "eu-west-1a"
}

