===============================================================================
                           Gathering All Subnet Name
===============================================================================

data "aws_availability_zones" "available" {
  state = "available"
}


===============================================================================
                                  VPC Creation
===============================================================================

resource "aws_vpc" "vpc" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "${var.project}-vpc"
  }
}

===============================================================================
                             Internet Gateway Creation
===============================================================================

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${var.project}-igw"
  }
}

===============================================================================
                                   Subnet pub1
===============================================================================


resource "aws_subnet" "pub1" {
        vpc_id     = aws_vpc.vpc.id
        cidr_block = cidrsubnet(var.vpc_cidr , var.sbit , 0)
        availability_zone = data.aws_availability_zones.available.names[0]
        map_public_ip_on_launch = true
  tags = {
    Name = "${var.project}-pub1"
  }
}


===============================================================================
                                   Subnet pub2
===============================================================================


resource "aws_subnet" "pub2" {
        vpc_id     = aws_vpc.vpc.id
        cidr_block = cidrsubnet(var.vpc_cidr , var.sbit , 1)
        availability_zone = data.aws_availability_zones.available.names[1]
        map_public_ip_on_launch = true
  tags = {
    Name = "${var.project}-pub2"
  }
}


===============================================================================
                                   Subnet pub3
===============================================================================


resource "aws_subnet" "pub3" {
        vpc_id     = aws_vpc.vpc.id
        cidr_block = cidrsubnet(var.vpc_cidr , var.sbit , 2)
        availability_zone = data.aws_availability_zones.available.names[2]
        map_public_ip_on_launch = true
  tags = {
    Name = "${var.project}-pub3"
  }
}

===============================================================================
                                   Subnet priv1
===============================================================================

resource "aws_subnet" "priv1" {
        vpc_id     = aws_vpc.vpc.id
        cidr_block = cidrsubnet(var.vpc_cidr , var.sbit , 3)
        availability_zone = data.aws_availability_zones.available.names[3]
        map_public_ip_on_launch = true
  tags = {
    Name = "${var.project}-priv1"
  }
}


===============================================================================
                                   Subnet priv2
===============================================================================

resource "aws_subnet" "priv2" {
        vpc_id     = aws_vpc.vpc.id
        cidr_block = cidrsubnet(var.vpc_cidr , var.sbit , 4)
        availability_zone = data.aws_availability_zones.available.names[4]
        map_public_ip_on_launch = true
  tags = {
    Name = "${var.project}-priv2"
  }
}

===============================================================================
                                   Subnet priv3
===============================================================================

resource "aws_subnet" "priv3" {
        vpc_id     = aws_vpc.vpc.id
        cidr_block = cidrsubnet(var.vpc_cidr , var.sbit , 5)
        availability_zone = data.aws_availability_zones.available.names[5]
        map_public_ip_on_launch = true
  tags = {
    Name = "${var.project}-priv3"
  }
}


===============================================================================
                          Creating Elastic Ip For Nat Gateway
===============================================================================

resource "aws_eip" "eip" {
  vpc      = true
  tags     = {
    Name = "${var.project}-eip"
  }
}


===============================================================================
                           Creating Elastic Ip For Nat Gateway
===============================================================================

resource "aws_nat_gateway" "ngw" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.pub1.id
  tags = {
    Name = "${var.project}-ngw"
  }
}


===============================================================================
                                  Public Route Table
===============================================================================

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id
  route  {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "${var.project}-public-rtb"
  }
}


===============================================================================
                                  Private Route Table
===============================================================================

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.vpc.id
  route  {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_nat_gateway.ngw.id
  }
  tags = {
    Name = "${var.project}-private-rtb"
  }
}

===============================================================================
                           Public Route Table Association
===============================================================================

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

===============================================================================
                           Private Route Table Association
===============================================================================

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


===============================================================================
                           Security Group Create - Bastion Server
===============================================================================

resource "aws_security_group" "bastion" {
  name        = "${var.project}-bastion"
  description = "allows access to port 22"
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

===============================================================================
                           Security Group Create - Webserver
===============================================================================

resource "aws_security_group" "webserver" {
  name        = "${var.project}-webserver"
  description = "allows access to ports 22,80 & 443"
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

===============================================================================
                           Security Group Create - Database Server
===============================================================================

resource "aws_security_group" "dbserver" {
  name        = "${var.project}-dbserver"
  description = "allows access to port 3306 and 22"
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
}


===============================================================================
                           EC2 Creation - Bastion Server
===============================================================================

resource "aws_instance" "bastion" {
    ami                          =  var.ami-id
    instance_type                =  var.ec2-type
    subnet_id                    =  aws_subnet.pub2.id
    key_name                     =  aws_key_pair.key.key_name
    associate_public_ip_address  =  true
    vpc_security_group_ids       =  [ aws_security_group.bastion.id ]
    tags  = {
       Name = "${var.project}-bastion"
    }
}

===============================================================================
                           EC2 Creation - Webserver
===============================================================================

resource "aws_instance" "webserver" {
    ami                          =  var.ami-id
    instance_type                =  var.ec2-type
    subnet_id                    =  aws_subnet.pub1.id
    key_name                     =  aws_key_pair.key.key_name
    associate_public_ip_address  =  true
    vpc_security_group_ids       =  [ aws_security_group.webserver.id ]
    tags  = {
       Name = "${var.project}-webserver"
    }
}


===============================================================================
                           EC2 Creation - Database Server
===============================================================================

resource "aws_instance" "dbserver" {
    ami                          =  var.ami-id
    instance_type                =  var.ec2-type
    subnet_id                    =  aws_subnet.priv1.id
    key_name                     =  aws_key_pair.key.key_name
    associate_public_ip_address  =  false
    vpc_security_group_ids       =  [ aws_security_group.dbserver.id ]
    tags  = {
       Name = "${var.project}-dbserver"
    }
}

