resource "aws_iam_instance_profile" "_" {
  name = "${var.namespace}-ec2-instance-profile"
  role = aws_iam_role._.name
}

resource "aws_iam_role" "_" {
  name               = "${var.namespace}-ec2-instance-role"
  assume_role_policy = file("./policies/ec2_assume_policy.json")
}

resource "aws_iam_role_policy" "ec2" {
  name = "${var.namespace}-ec2-policy"
  role = aws_iam_role._.id
  policy = templatefile("./policies/ec2_role_policy.tpl", {
    permitted_buckets = var.permitted_buckets
  })
}

resource "aws_instance" "_" {
  ami                    = var.server_ami
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.ec2.id]
  subnet_id              = var.subnet_id
  iam_instance_profile   = aws_iam_instance_profile._.name

  lifecycle {
    ignore_changes = [ami]
  }

  tags = {
    Name                = var.namespace
    DeploymentGroupName = var.namespace
  }

  root_block_device {
    volume_size = var.storage_size
  }
}

resource "aws_eip" "eip" {
  instance = aws_instance._.id
  domain   = "vpc"
}
