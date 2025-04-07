# Output VPC ID
output "vpc_id" {
  value = aws_vpc.Main_VPC.id
  description = "The ID of the main VPC"
}

# Output Subnet ID
output "subnet_id" {
  value = aws_subnet.Main_Subnet.id
  description = "The ID of the main subnet"
}

# Output Internet Gateway ID
output "internet_gateway_id" {
  value = aws_internet_gateway.gw.id
  description = "The ID of the Internet Gateway"
}

# Output Route Table ID
output "route_table_id" {
  value = aws_route_table.Main_VPC_Route_Table.id
  description = "The ID of the main route table"
}

# Output Route Table Association
output "route_table_association_id" {
  value = aws_route_table_association.a.id
  description = "The ID of the route table association"
}
