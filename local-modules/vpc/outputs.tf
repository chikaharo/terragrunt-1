output "main_vpc" {
  value = aws_vpc.main_vpc
}

output "vpc_id" {
  value = aws_vpc.main_vpc.id
}

output "nat" {
  value = aws_eip.nat_gw_eip
}

output "private_subnet_1" {
  value = aws_subnet.private_subnet_1
}

output "private_subnet_1_id" {
  value = aws_subnet.private_subnet_1.id
}
output "private_subnet_2" {
  value = aws_subnet.private_subnet_2
}

output "private_subnet_2_id" {
  value = aws_subnet.private_subnet_2.id
}

output "public_subnet_1" {
  value = aws_subnet.public_subnet_1
}

output "public_subnet_1_id" {
  value = aws_subnet.public_subnet_1.id
}

output "public_subnet_2" {
  value = aws_subnet.public_subnet_2
}

output "public_subnet_2_id" {
  value = aws_subnet.public_subnet_2.id
}
