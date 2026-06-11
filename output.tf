# get the instance public ip
output "minecraft_ip" {
  value = aws_instance.minecraft.public_ip
}
