provider "aws" {
  region = "ap-south-1"
}

# VPC creation
resource "aws_vpc" "infra_vpc" {    // Resource name here infra_vpc
  cidr_block = "10.0.0.0/16"
    tags = {
      Name = "MyProjectVpc"
    }
}

# Subnet creation
resource "aws_subnet" "infra_subnet" {
  vpc_id = aws_vpc.infra_vpc.id      // Reference to the VPC created above so as to link the subnet to it to this particular VPC
  cidr_block       = "10.0.1.0/24"
  availability_zone = "ap-south-1a"  // AWS should know in which AZ we want to create this subnet
    tags = {
      Name = "MyProjectSubnet"
    }
  map_public_ip_on_launch = true  // This will assign public IP to instances launched in this subnet
}

# Internet Gateway creation
resource "aws_internet_gateway" "infra_igw" {
  vpc_id = aws_vpc.infra_vpc.id
    tags = {
      Name = "MyProjectIgw"
    }
}

# Route Table creation
resource "aws_route_table" "infra_rt" {
  vpc_id = aws_vpc.infra_vpc.id

  //after creating the route table with the VPC, we need to add route

  route {
    cidr_block = "0.0.0.0/0"   // This is for all IPv4 traffic
    gateway_id = aws_internet_gateway.infra_igw.id
  }
    tags = {
      Name = "MyProjectRT"
    }
}

# Attach the route table to the subnet
resource "aws_route_table_association" "infra_rta" {
  subnet_id      = aws_subnet.infra_subnet.id
  route_table_id = aws_route_table.infra_rt.id
}

# EC2 Instance creation -> 4 instances - 3 for runnning apps and 1 for using Ansible
resource "aws_instance" "infra_instance" {
  ami           = "ami-02d26659fd82cf299" // Ubuntu , SSD Volume Type for ap-south-1 region
  instance_type = "t2.micro"
  key_name      = "sampleec2"         //premade key pair created in AWS console by me earlier
  subnet_id     = aws_subnet.infra_subnet.id
  count         = 4                       // This will create 4 instances of this type

  tags = {
    Name = "AppServer-${count.index + 1}" // Naming instances as AppServer-1, AppServer-2, AppServer-3
  }
  vpc_security_group_ids = [aws_security_group.infra_sg.id] // Associating security group created above to this instance
  // This is a list so using [] why because we can attach multiple security groups to an instance max is 5 security groups for an instance 
}

# Security Group creation
resource "aws_security_group" "infra_sg" {
  vpc_id      = aws_vpc.infra_vpc.id

  ingress  {                         // Ingress means incoming traffic/inbound rules opposite is egress
    description = "SSH"
    from_port   = 22              // Allowing SSH access for exactly port 22 ie from port 22 to port 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] // Allowing from any IP address
  }

  egress {
    description = "All traffic"
    from_port   = 0             // Allowing all outbound traffic from port 0 to all ports  
    to_port     = 0
    protocol    = "-1"           // -1 means all protocols
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "MyProjectSG"
  }

}