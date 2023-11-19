resource "aws_instance" "bastion-ec2" {
  ami           = var.ami
  instance_type = var.instance_type
  subnet_id     = var.subnet_id
  vpc_security_group_ids= var.sg_id
  key_name = "ec2-access-key"
  tags = {
    Name = "Bastion"
  }
}
