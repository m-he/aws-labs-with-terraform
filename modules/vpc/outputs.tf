output "vpc_id" { value = aws_vpc.main.id }
output "vpc_cidr_block" { value = aws_vpc.main.cidr_block }
output "private_subnet_ids" { value = [for s in aws_subnet.private : s.id] }
output "public_subnet_ids" { value = [for s in aws_subnet.public : s.id] }
output "cluster_name" { value = local.cluster_name }
output "nat_gateway_ids" { value = [for n in aws_nat_gateway.nat : n.id] }
