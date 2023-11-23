output "ec2_instance" {
  value = aws_instance._
}

output "public_ipv4_address" {
  value = aws_eip.eip.public_ip
}

output "ec2_instance_role" {
  value = aws_iam_role._
}
