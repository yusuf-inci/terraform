resource "aws_vpc" "baytera" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  tags = {
    Name = "vprofile"
  }
}

resource "aws_subnet" "baytera-pub-1" {
  vpc_id                  = aws_vpc.baytera.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = var.ZONE1
  tags = {
    Name = "baytera-pub-1"
  }
}

resource "aws_subnet" "baytera-pub-2" {
  vpc_id                  = aws_vpc.baytera.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = var.ZONE2
  tags = {
    Name = "baytera-pub-2"
  }
}

resource "aws_subnet" "baytera-pub-3" {
  vpc_id                  = aws_vpc.baytera.id
  cidr_block              = "10.0.3.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = var.ZONE3
  tags = {
    Name = "baytera-pub-3"
  }
}

resource "aws_subnet" "baytera-priv-1" {
  vpc_id                  = aws_vpc.baytera.id
  cidr_block              = "10.0.4.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = var.ZONE1
  tags = {
    Name = "baytera-priv-1"
  }
}


resource "aws_subnet" "baytera-priv-2" {
  vpc_id                  = aws_vpc.baytera.id
  cidr_block              = "10.0.5.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = var.ZONE2
  tags = {
    Name = "baytera-priv-2"
  }
}


resource "aws_subnet" "baytera-priv-3" {
  vpc_id                  = aws_vpc.baytera.id
  cidr_block              = "10.0.6.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = var.ZONE3
  tags = {
    Name = "baytera-priv-3"
  }
}

resource "aws_internet_gateway" "baytera-IGW" {
  vpc_id = aws_vpc.baytera.id
  tags = {
    Name = "baytera-IGW"
  }
}

resource "aws_route_table" "baytera-pub-RT" {
  vpc_id = aws_vpc.baytera.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.baytera-IGW.id
  }

  tags = {
    Name = "baytera-pub-RT"
  }

}

resource "aws_route_table_association" "baytera-pub-1-a" {
  subnet_id      = aws_subnet.baytera-pub-1.id
  route_table_id = aws_route_table.baytera-pub-RT.id
}

resource "aws_route_table_association" "baytera-pub-2-a" {
  subnet_id      = aws_subnet.baytera-pub-2.id
  route_table_id = aws_route_table.baytera-pub-RT.id
}

resource "aws_route_table_association" "baytera-pub-3-a" {
  subnet_id      = aws_subnet.baytera-pub-3.id
  route_table_id = aws_route_table.baytera-pub-RT.id
}