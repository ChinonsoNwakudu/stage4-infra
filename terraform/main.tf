provider "aws" {
  region = var.aws_region
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# resource "aws_key_pair" "deploy_key" {
#   key_name   = var.key_name
#   public_key = file("/Users/user/.ssh/chin-key.pub")  # Update path to your public key
# }

resource "aws_security_group" "app_sg" {
  name        = "devops-stage-4-sg"
  description = "Security group for DevOps-Stage-4 app"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8088
    to_port     = 8088
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "app_server" {
  ami           = "ami-04b4f1a9cf54c11d0"  # Ubuntu 22.04 us-east-1 (update for your region)
  instance_type = var.instance_type
  key_name      = var.key_name
  vpc_security_group_ids = [aws_security_group.app_sg.id]
  subnet_id     = data.aws_subnets.default.ids[0]
  associate_public_ip_address = true

  tags = {
    Name = "DevOps-Stage-4-Server"
  }
}

resource "aws_eip" "app_eip" {
  instance = aws_instance.app_server.id
}

resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/ansible_inventory.tmpl", {
    app_server_ip = aws_eip.app_eip.public_ip
  })
  filename = "${path.module}/../ansible/inventory.yml"
}

resource "null_resource" "ansible_provision" {
  depends_on = [local_file.ansible_inventory, aws_instance.app_server]

  provisioner "local-exec" {
    command = "sleep 30 && ansible-playbook -i ../ansible/inventory.yml ../ansible/playbook.yml"
    working_dir = path.module
  }
}