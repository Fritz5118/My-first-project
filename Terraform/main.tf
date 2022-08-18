provider "aws" {
    region = "us-east-1"
  
}

resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "main"
  }
}

resource "aws_subnet" "public" {
  vpc_id           = aws_vpc.main.id
  cidr_block       = "10.0.0.0/24"
  
  tags = {
    Name = "Public Subnet"
  }
}
resource "aws_subnet" "public1" {
  vpc_id           =  aws_vpc.main.id
  cidr_block       = "10.0.1.0/24"
  
  tags = {
    Name = "Public Subnet 2"
  }
}
resource "aws_subnet" "private" {
  vpc_id    = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "Private Subnet"
  }
}
resource "aws_subnet" "private1" {
  vpc_id    = aws_vpc.main.id
  cidr_block = "10.0.3.0/24"
  tags = {
    Name = "Private Subnet2"
  }
}
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "geteway1"
  }
}
resource "aws_eip" "nat_eip" {
  vpc     = true
  depends_on = [aws_internet_gateway.gw]
  tags = {
    "name" = "NAT Geteway EIP"
  }

}
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id = aws_subnet.private.id
  tags = {
    "Name" = "Main NAT Gateway"
  }
}
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    carrier_gateway_id = aws_internet_gateway.gw.id 
  } 
  tags = {
      Name = "Public Route Table"
    }
}
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    carrier_gateway_id = aws_nat_gateway.nat.id
  } 
   tags = {
      Name = "Private Route Table"
    }
}
resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}
