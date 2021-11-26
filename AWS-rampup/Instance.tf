 #1 Create a VPC
resource "aws_vpc" "ramp-vpc" {
    cidr_block = "10.0.0.0/16"
        tags ={
            Name = "Ramp-up"
  }
 }

 #2 Create internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.ramp-vpc.id
  tags = {
    Name = "Ramp"
  }
}

#3 Create custom route table
resource "aws_route_table" "prod-rout-table" {
  vpc_id = aws_vpc.ramp-vpc.id
  route  {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.gw.id
    }
    route {
      ipv6_cidr_block        = "::/0"
      gateway_id= aws_internet_gateway.gw.id
    }

  tags = {
    Name = "Prod"
  }
}

#4 Create a subnet 
resource "aws_subnet" "subnet-1" {
  vpc_id     = aws_vpc.ramp-vpc.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone = "us-east-1a"
  tags = {
    Name = "Ramp-subnet1"
  }
 }

 #4.1 Create a subnet 
resource "aws_subnet" "subnet-2" {
  vpc_id     = aws_vpc.ramp-vpc.id
  cidr_block = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone = "us-east-2"
  tags = {
    Name = "Ramp-subnet2"
  }
 }

 #4.2 Create a Public subnet
resource "aws_subnet" "subnet-3" {
  vpc_id     = aws_vpc.ramp-vpc.id
  cidr_block = "10.0.3.0/24"
  map_public_ip_on_launch = false
  availability_zone = "us-east-1a"
  tags = {
    Name = "Ramp-subnet3"
  }
 }

 #5 Associate subnet with a route table
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.subnet-1.id
  route_table_id = aws_route_table.prod-rout-table.id
}

#6 Create a security group to allow port 22,80,443
resource "aws_security_group" "allow_web" {
  name        = "allow_web_traffic"
  description = "Allow web inbound traffic"
  vpc_id      = aws_vpc.prod-vpc.id

  ingress  {
      description      = "HTTPS"
      from_port        = 443
      to_port          = 443
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  

    ingress  {
      description      = "HTTP"
      from_port        = 80
      to_port          = 80
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  

    ingress   {
      description      = "SSH"
      from_port        = 22
      to_port          = 22
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  

  egress  {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }

  tags = {
    Name = "allow_web"
  }
}

#7 Create a network interface with an ip in the subnet that was created in step 4
resource "aws_network_interface" "web-server-nic1" {
  subnet_id       = aws_subnet.subnet-1.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.allow_web.id]
}

resource "aws_network_interface" "web-server-nic2" {
  subnet_id       = aws_subnet.subnet-2.id
  private_ips     = ["10.0.1.51"]
  security_groups = [aws_security_group.allow_web.id]
}

resource "aws_network_interface" "web-server-nic3" {
  subnet_id       = aws_subnet.subnet-1.id
  private_ips     = ["10.0.1.52"]
  security_groups = [aws_security_group.allow_web.id]
}

resource "aws_network_interface" "web-server-nic4" {
  subnet_id       = aws_subnet.subnet-1.id
  private_ips     = ["10.0.1.53"]
  security_groups = [aws_security_group.allow_web.id]
}

#8 Assign an elastic IP to the network interface created on setp 7
resource "aws_eip" "one" {
  vpc                       = true
  network_interface         = aws_network_interface.web-server-nic1.id
  associate_with_private_ip = "10.0.1.50"
}

output "server_public_ip" {
  value = aws_eip.one.public_ip
}

#9 Create a Ubuntu server
resource "aws_instance" "example" {
  ami           = var.AMIS[var.AWS_REGION]
  instance_type = "t2.micro"
}

