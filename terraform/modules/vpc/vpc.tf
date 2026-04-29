# VPC

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "${var.project_name}-vpc"
    Environment = "production"
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

# Public Subnets (One per AZ)

resource "aws_subnet" "public" {
  count             = length(var.public_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-public-subnet-${count.index == 0 ? "A" : "B"}"
    Type = "public"
  }
}

# Private Subnets (One per AZ)

resource "aws_subnet" "private" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
  Name = "${var.project_name}-private-subnet-${count.index == 0 ? "A" : "B"}"
  Type = "private"
  }
}

# Internet Gateway

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-igw"
  }
}

# Elastic IP

resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "${var.project_name}-nat-eip"
  }

  depends_on = [aws_internet_gateway.main]

}
  
# NAT Gateway
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id

  tags = {
    Name = "${var.project_name}-nat-gateway"
  }

  depends_on = [aws_internet_gateway.main]
}

# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.project_name}-PublicRouteTable"
  }
}

# Public Subnet Association

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public[count.index].id
  count          = length(var.public_subnet_cidrs)
  route_table_id = aws_route_table.public.id
}

# Private Route Table

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }

  tags = {
    Name = "${var.project_name}-PrivateRouteTable"
  }
}

# Private Route Table Association

resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private[count.index].id
  count          = length(var.private_subnet_cidrs)
  route_table_id = aws_route_table.private.id
}

# # ALB Security Groups

# resource "aws_security_group" "alb" {
#   name        = "alb-sg"
#   description = "Security group for Application Load Balancer"
#   vpc_id      = aws_vpc.main.id


# ingress {
#    description  = "HTTP from internet"
#    from_port    = 80
#    to_port      = 80
#    protocol     = "tcp"
#    cidr_blocks  = ["0.0.0.0/0"]
# }

# ingress {
#    description  = "HTTPs from internet"
#    from_port    = 443
#    to_port      = 443
#    protocol     = "tcp"
#    cidr_blocks  = ["0.0.0.0/0"]
# }

# egress {
#     description  = "Allow all outbound"
#     from_port    = 0
#     to_port      = 0
#     protocol     = "-1"
#     cidr_blocks  = ["0.0.0.0/0"]
# }

#     tags = {
#       Name = "alb-sg"
#   }
# } 

# # ECS Security Group

# resource "aws_security_group" "ecs" {
#   name        = "ecs-sg"
#   description = "Security group for ECS tasks"
#   vpc_id      = aws_vpc.main.id

# ingress {
#   description      = "Allow traffic from ALB"
#    from_port       = 8080
#    to_port         = 8080
#    protocol        = "tcp"
#    security_groups = [aws_security_group.alb.id]
# }

# egress {
#     description  = "Allow all outbound"
#     from_port    = 0
#     to_port      = 0
#     protocol     = "-1"
#     cidr_blocks  = ["0.0.0.0/0"]
# }

#     tags = {
#       Name = "ecs-sg"
#   }
# }