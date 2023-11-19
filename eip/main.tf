resource "aws_eip" "demo-eip" {
  instance = var.instance
  vpc      = true
}