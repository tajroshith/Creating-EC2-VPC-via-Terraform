output "aws_eip" {
value = aws_eip.eip.public_ip
}
output "aws_vpc" {
value = aws_vpc.vpc.id
}
output "aws_internet_gateway" {
value = aws_internet_gateway.igw.id
}
output "aws_nat_gateway" {
value = aws_nat_gateway.nat.id
}
output "aws_route_table_public" {
value = aws_route_table.public.id
}
output "aws_route_table_private" {
value = aws_route_table.private.id
}
output "aws_instance" {
value = aws_route_table.bastion.id
}
output "aws_instance" {
value = aws_route_table.webserver.id
}
output "aws_instance" {
value = aws_route_table.dbserver.id
}