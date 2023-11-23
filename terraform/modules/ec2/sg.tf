resource "aws_security_group" "ec2" {
  name = "${var.namespace}-ec2-sg"

  description = "EC2 security group (terraform-managed)"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = toset([22, 80, 443])

    content {
      from_port        = ingress.key
      to_port          = ingress.key
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  }

  # Allow all outbound traffic.
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

