output "vpc" {
  value = aws_vpc._
}

output "public_subnet" {
  value = aws_subnet.public
}

output "private_subnet" {
  value = aws_subnet.private
}
