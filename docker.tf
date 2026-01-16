# configured aws provider with proper credentials
provider "aws" {
  region = "us-east-1"
  profile= "MENWITHTASTE"
}

# Create a remote backend for your terraform 
terraform {
  backend "s3" {
    bucket = "menwithtaste-dockerv2"
    dynamodb_table = "docker-state"
    key    = "LockID"
    region = "us-east-1"
    profile = "MENWITHTASTE"
  }
}


# create default vpc if one does not exit
resource "aws_default_vpc" "default_vpc" {

  tags    = {
    Name  = "default vpc"
  }
}


# use data source to get all avalablility zones in region
data "aws_availability_zones" "available_zones" {}


# create default subnet if one does not exit
resource "aws_default_subnet" "default_az1" {
  availability_zone = data.aws_availability_zones.available_zones.names[0]

  tags   = {
    Name = "default subnet"
}
}


# create security group for the ec2 instance
resource "aws_security_group" "ec2_security_group" {
  name        = "ec2 security group"
  description = "allow access on ports 8080 and 22"
  vpc_id      = aws_default_vpc.default_vpc.id

  # allow access on port 8080
  ingress {
    description      = "http proxy access"
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

   ingress {
    description      = "http proxy access"
    from_port        = 6709
    to_port          = 6709
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

   ingress {
    description      = "http proxy access"
    from_port        = 1576
    to_port          = 1576
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  # allow access on port 22
  ingress {
    description      = "ssh access"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "http proxy-nginx access"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "http nginx access"
    from_port        = 9090
    to_port          = 9090
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "http nginx access"
    from_port        = 8070
    to_port          = 8070
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = -1
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags   = {
    Name = "Docker server security group"
  }
}


# use data source to get a registered amazon linux 2 ami
data "aws_ami" "ubuntu" {

    most_recent = true

    filter {
        name   = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
    }

    filter {
        name = "virtualization-type"
        values = ["hvm"]
    }

    owners = ["099720109477"]
}

# launch the ec2 instance and install website
resource "aws_instance" "ec2_instance1" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  subnet_id              = aws_default_subnet.default_az1.id
  vpc_security_group_ids = [aws_security_group.ec2_security_group.id]
key_name               = "menwithtasteKPv2"
  user_data            = "${file("docker-install.sh")}"

  tags = {
    Name = "Docker-server"
  }
}

# print the url of the docker server
output "website_url" {
  value     = join ("", ["http://", aws_instance.ec2_instance1.public_dns])
}
