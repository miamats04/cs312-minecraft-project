# generate a private key
resource "tls_private_key" "minecraft_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# save the private key to a local file
resource "local_file" "minecraft_private_key" {
  content  = tls_private_key.minecraft_key.private_key_pem
  filename = "${path.root}/minecraft_key.pem"
  file_permission = "0400"
}

# create a key pair using the generated public key
resource "aws_key_pair" "minecraft_key" {
  key_name   = "minecraft_project2_key"
  public_key = tls_private_key.minecraft_key.public_key_openssh
}


# set up security group
resource "aws_security_group" "minecraft_sg" {
  name        = "minecraft_sg"
  description = "Allow SSH and Minecraft traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "ssh"
  }

  ingress {
    from_port   = 25565
    to_port     = 25565
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "minecraft"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# set up ec2 instance
resource "aws_instance" "minecraft" {
  ami                    = "ami-091138d0f0d41ff90" # Ubuntu 26.04 LTS (free tier)
  instance_type          = "t3.small"              # free tier
  vpc_security_group_ids = [aws_security_group.minecraft_sg.id]
  key_name               = aws_key_pair.minecraft_key.key_name

  tags = {
    Name = "minecraft-project2"
  }
}