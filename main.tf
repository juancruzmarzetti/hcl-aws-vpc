resource "aws_vpc" "Main" {                
    cidr_block = var.main_vpc_cidr     
    instance_tenancy = "default"
    tags = {
        Name = "My_VPC"
    }
}

resource "aws_internet_gateway" "IGW" {    
    vpc_id =  aws_vpc.Main.id               
    tags = {
        Name = "IGW"
    }
}

resource "aws_subnet" "public_subnets" {    
    vpc_id =  aws_vpc.Main.id
    cidr_block = var.public_subnets        
    tags = {
        Name = "Public Subnet"
    }
}

resource "aws_subnet" "private_subnets" {
    vpc_id =  aws_vpc.Main.id
    cidr_block = var.private_subnets          
    tags = {
        Name = "Private Subnet"
    }
}

resource "aws_route_table" "Public_RT" {    
    vpc_id =  aws_vpc.Main.id
    route {
        cidr_block = "0.0.0.0/0"               
        gateway_id = aws_internet_gateway.IGW.id
    }
    tags = {
        Name = "Tabla de Ruteo Pública"
    }
}

resource "aws_route_table" "Private_RT" {    
    vpc_id = aws_vpc.Main.id
    route {
        cidr_block = "0.0.0.0/0"             
        nat_gateway_id = aws_nat_gateway.NAT_GW.id
    }
    tags = {
        Name = "Tabla de Ruteo Privada"
    }
}

resource "aws_route_table_association" "Public_RT_Association" {
   subnet_id = aws_subnet.public_subnets.id
   route_table_id = aws_route_table.Public_RT.id
}

resource "aws_route_table_association" "Private_RT_Association" {
   subnet_id = aws_subnet.private_subnets.id
   route_table_id = aws_route_table.Private_RT.id
}

resource "aws_eip" "NAT_EIP" {
    vpc   = true
    tags = {
        Name = "NAT con elastic IP"
    }
}

resource "aws_nat_gateway" "NAT_GW" {
    allocation_id = aws_eip.NAT_EIP.id
    subnet_id = aws_subnet.public_subnets.id
    tags = {
        Name = "NAT Gateway alocada a la subnet pública"
    }
}