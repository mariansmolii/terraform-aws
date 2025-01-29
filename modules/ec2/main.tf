data "aws_ami" "this" {
  most_recent = true

  filter {
    name   = "name"
    values = [var.ami_name]
  }

  filter {
    name   = "architecture"
    values = [var.architecture]
  }

  owners = [var.ami_owner]
}

resource "aws_instance" "this" {
  ami           = data.aws_ami.this.id
  instance_type = var.instance_type
  subnet_id     = var.subnet_id
  key_name      = var.key_name

  vpc_security_group_ids = var.security_group_ids

  tags = {
    Name = "${var.environment}-${var.instance_name}"
  }
}