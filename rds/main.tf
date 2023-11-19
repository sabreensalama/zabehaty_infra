 data "aws_ssm_parameter" "mysql_username" {
  name = "/mysql/username"
}
data "aws_ssm_parameter" "mysql_password" {
  name = "/mysql/password"
}
data "aws_ssm_parameter" "db_name" {
  name = "/mysql/db_name"
} 
resource "aws_db_subnet_group" "subnet_group" {
  name       = "airflow-group"
  subnet_ids = var.subnet_id

  tags = {
    Name = "mysql"
  }
}

resource "aws_db_instance" "default" {
  identifier = "zabehaty-db"
  allocated_storage    = var.storage
  db_name              = data.aws_ssm_parameter.db_name.value
  engine               = var.engine
  engine_version       = var.engine_version
  instance_class       = var.instance_type
  username             = data.aws_ssm_parameter.mysql_username.value
  password             = data.aws_ssm_parameter.mysql_password.value
  skip_final_snapshot  = true
  db_subnet_group_name = aws_db_subnet_group.subnet_group.name
  vpc_security_group_ids = var.sg


}
