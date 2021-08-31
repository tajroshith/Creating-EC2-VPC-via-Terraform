# VPC & EC2 Creation via Terraform

[![Build Status](https://travis-ci.org/joemccann/dillinger.svg?branch=master)](https://travis-ci.org/joemccann/dillinger)

In this project we are going to create VPC and EC2 instances through terraform, we need 3 EC2 instances one webserver, one db server and a bastion server that can give us ssh access to both webserver and db server. The database server is created in a private subnet and other instances are in public subnet.

## List of AWS resources created through terraform

- EC2 Instances
- Security Group
- AMI (Amazon Machine Image)
- Key-Pair
- Internet Gateway
- Nat Gateway
- Route Tables
- VPC

## Features

- Easy to customise and use.
- Each subnet CIDR block created through automation.
- Using tfvars file to access and modify variables.
- Project and name tag is appended to the resources that we are creating.

## Pre-requisites for this project

- Need AWS CLI access or IAM user access with attached policies for the creation of VPC.
- Terraform need to be installed in your system.
- Knowledge to the working principles of each AWS services especially VPC, EC2 and IP Subnetting.

### Creating variables.tf

First lets create a file for declaring our variables, Create a variables.tf file and we define the following variables

```sh
variable "region" {}
variable "access_key" {}
variable "secret_key" {}
variable "project" {}
variable "vpc_cidr" {}
variable "sbit" {}
variable "name" {}
```

values declared here are passing through the terrafrom.tfvars file.

### Creating provider.tf 

Now lets create our provider.tf file which defines our provider.

```sh
provider "aws" {
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}
```

### Creating terraform.tfvars

By default terraform.tfvars will load the variables to the the resources. we can modify accordingly as per our requirements.

```sh
region     = "put-your-region-here"
access_key = "put-your-access-key-here"
secret_key = "put-your-secret-key-here"
project =    "put-your-project-tag"
name     =   "put-your-name-tag"
vpc_cidr =   "X.X.X.X/X"
sbit     =   "X"
```
we can define our subnet bit here so that it automates the creation of CIDR Block.

Now we move to initialize terraform configuration files using the below command.

```sh
terraform init.
```

Once successfully initialized we move on to create our infrastructure and EC2 instances. Lets start by creating our main.tf file with the details below:

Creating VPC

```sh
resource "aws_vpc" "vpc" {

  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "${var.project}-vpc"
    Project  = "${var.name}"
  }
}
```

To Fetch Availability Zones for creation of subnets

```sh
data "aws_availability_zones" "available" {
  state = "available"
}
```

To Create Internet Gateway For VPC

```sh
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${var.project}-igw"
    Project  = "${var.name}"
  }
}
```

The infrastructure we are creating requires 3 public and 3 private subnets as such i have choosen the region "us-east-1" which gives us 6 availability zones. You can choose your region and modify according to the Availability Zone. 
As mentioned earlier we have already provided the CIDR block in our terraform.tfvars file so that we dont need to calculate the subnets, here we use terraform to automate the subnetting.

Creating "pub1" Public Subnet

```sh
resource "aws_subnet" "pub1" {
	vpc_id     = aws_vpc.vpc.id
	cidr_block = cidrsubnet(var.vpc_cidr , var.sbit , 0)
	availability_zone = data.aws_availability_zones.available.names[0]
	map_public_ip_on_launch = true
  tags = {
    Name = "${var.project}-pub1"
    Project  = "${var.name}"
  }
}
```

Creating "pub2" Public Subnet

```sh
resource "aws_subnet" "pub2" {
	vpc_id     = aws_vpc.vpc.id
	cidr_block = cidrsubnet(var.vpc_cidr , var.sbit , 1)
	availability_zone = data.aws_availability_zones.available.names[1]
	map_public_ip_on_launch = true
  tags = {
    Name = "${var.project}-pub2"
    Project  = "${var.name}"
  }
}
```
Creating "pub3" Public Subnet

```sh
resource "aws_subnet" "pub3" {
	vpc_id     = aws_vpc.vpc.id
	cidr_block = cidrsubnet(var.vpc_cidr , var.sbit , 2)
	availability_zone = data.aws_availability_zones.available.names[2]
	map_public_ip_on_launch = true
  tags = {
    Name = "${var.project}-pub3"
    Project  = "${var.name}"
  }
}
```
Creating "priv1" Private Subnet

```sh
resource "aws_subnet" "priv1" {
	vpc_id     = aws_vpc.vpc.id
	cidr_block = cidrsubnet(var.vpc_cidr , var.sbit , 3)
	availability_zone = data.aws_availability_zones.available.names[3]
	map_public_ip_on_launch = true
  tags = {
    Name = "${var.project}-priv1"
    Project  = "${var.name}"
  }
}
```

Creating "priv2" Private Subnet

```sh
resource "aws_subnet" "priv2" {
	vpc_id     = aws_vpc.vpc.id
	cidr_block = cidrsubnet(var.vpc_cidr , var.sbit , 4)
	availability_zone = data.aws_availability_zones.available.names[4]
	map_public_ip_on_launch = true
  tags = {
    Name = "${var.project}-priv2"
    Project  = "${var.name}"
  }
}
```

Creating "priv3" Private Subnet

```sh
resource "aws_subnet" "priv3" {
	vpc_id     = aws_vpc.vpc.id
	cidr_block = cidrsubnet(var.vpc_cidr , var.sbit , 5)
	availability_zone = data.aws_availability_zones.available.names[5]
	map_public_ip_on_launch = true
  tags = {
    Name = "${var.project}-priv3"
    Project  = "${var.name}"
  }
}
```

Creating Elastic IP For Nat Gateway

```sh
resource "aws_eip" "eip" {
  vpc      = true
  tags     = {
    Name = "${var.project}-eip"
    Project  = "${var.name}"
  }
}
```

Attaching Elastic IP to NAT gateway

```sh
resource "aws_nat_gateway" "ngw" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.pub1.id
  tags = {
    Name = "${var.project}-ngw"
    Project  = "${var.name}"
  }
}
```

Creating Public Route Table

```sh
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id
  route  {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "${var.project}-public-rtb"
    Project  = "${var.name}"
  }
}
```

Creating Private Route Table

```sh
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.vpc.id
  route  {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_nat_gateway.ngw.id
  }
  tags = {
    Name = "${var.project}-private-rtb"
    Project  = "${var.name}"
  }
}
```

Creating Public Route Table Association

```sh
resource "aws_route_table_association" "pub1" {
  subnet_id      = aws_subnet.pub1.id
  route_table_id = aws_route_table.public.id
}
resource "aws_route_table_association" "pub2" {
  subnet_id      = aws_subnet.pub2.id
  route_table_id = aws_route_table.public.id
}
resource "aws_route_table_association" "pub3" {
  subnet_id      = aws_subnet.pub3.id
  route_table_id = aws_route_table.public.id
}
```

Creating Private Route Table Association

```sh
resource "aws_route_table_association" "priv1" {
  subnet_id      = aws_subnet.priv1.id
  route_table_id = aws_route_table.private.id
}
resource "aws_route_table_association" "priv2" {
  subnet_id      = aws_subnet.priv2.id
  route_table_id = aws_route_table.private.id
}
resource "aws_route_table_association" "priv3" {
  subnet_id      = aws_subnet.priv3.id
  route_table_id = aws_route_table.private.id
}
```

Creating Key-Pair for Our EC2 Instances

```sh
resource "aws_key_pair" "key" {
	key_name =   "terraform-key"
	public_key = file("terraform.pub")
tags = {
	Name = "${var.project}-key"
        Project  = "${var.name}"
  }
 }
 ```
 
 Creating Security Group for Bastion Server

```sh
resource "aws_security_group" "bastion" {

  name        = "${var.name}-bastion"
  description = "Allows access to port 22"
  vpc_id      =  aws_vpc.vpc.id

  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  tags = {
    Name = "${var.project}-bastion"
  }
}
```

Creating Security Group for Webserver

```sh
resource "aws_security_group" "webserver" {

  name        = "${var.name}-webserver"
  description = "Allows access to ports 22,80 & 443"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  ingress {
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
    ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    security_groups  = [ aws_security_group.bastion.id ]
  } 
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  tags = {
    Name = "${var.project}-webserver"
  }
}
```

Creating Security Group for Database Server

```sh
resource "aws_security_group" "dbserver" {

  name        = "${var.name}-dbserver"
  description = "Allows access to port 3306 and 22"
  vpc_id      =  aws_vpc.vpc.id

  ingress {
    from_port        = 3306
    to_port          = 3306
    protocol         = "tcp"
    security_groups  = [ aws_security_group.webserver.id ]
  }
 ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    security_groups  = [ aws_security_group.bastion.id ]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  tags = {
    Name = "${var.project}-dbserver"
  }
}
```

Creating EC2 Instance Bastion Server

```sh
resource "aws_instance" "bastion" {

    ami                          =  "ami-0c2b8ca1dad447f8a"
    instance_type                =  "t2.micro"
    subnet_id      		 =  aws_subnet.pub2.id
    key_name                     =  aws_key_pair.key.key_name
    associate_public_ip_address  =  true
    vpc_security_group_ids       =  [ aws_security_group.bastion.id ]
    tags  = {
       Name = "${var.project}-bastion"
       Project  = "${var.name}"
    }
}
```

Creating EC2 Instance Webserver

```sh
resource "aws_instance" "webserver" {

    ami                          =  "ami-0c2b8ca1dad447f8a"
    instance_type                =  "t2.micro"
    subnet_id      		 =  aws_subnet.pub1.id
    key_name                     =  aws_key_pair.key.key_name
    associate_public_ip_address  =  true
    vpc_security_group_ids       =  [ aws_security_group.webserver.id ]
    tags  = {
       Name     = "${var.project}-webserver"
       Project  = "${var.name}"
    }
}
```

Creating EC2 Instance Database Server

```sh
resource "aws_instance" "dbserver" {

    ami                          =  "ami-0c2b8ca1dad447f8a"
    instance_type                =   "t2.micro"
    subnet_id      		 =  aws_subnet.priv1.id
    key_name                     =  aws_key_pair.key.key_name
    associate_public_ip_address  =  false
    vpc_security_group_ids       =  [ aws_security_group.dbserver.id ]
    tags  = {
       Name = "${var.project}-dbserver"
       Project  = "${var.name}"
    }
}
```

Now lets validate the terraform files using

```sh
terraform validate
```

Lets plan the architecture
```sh
terraform plan
```
Lets apply the above architecture to the AWS
```sh
terraform apply
```
