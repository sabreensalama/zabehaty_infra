resource "aws_launch_template" "web_lt" {
  name                                 = var.template_name
  image_id                             = var.image_id
  instance_type                        = var.instance_type
  key_name = "ec2-access-key"
  vpc_security_group_ids = var.sg_id
  update_default_version =  true
  iam_instance_profile {
    name = "ecr-pull-cicd-role"
  } 
  block_device_mappings {
  device_name = "/dev/sda1"
    ebs {
      volume_size = 30
      delete_on_termination = true
      volume_type = "gp2" # default is gp2
     }
  }
  user_data = filebase64("${path.module}/user_data.sh")
    tag_specifications {
     resource_type = "instance"
     tags = {
    Name = "zabehaty"
    project = "zabehaty"
    }
    }
}
resource "aws_autoscaling_group" "web_asg" {
  name                      = "zabehty_asg"
  vpc_zone_identifier = var.asg_subnets
  health_check_type         = "EC2"
  health_check_grace_period = 120
  termination_policies      = ["OldestInstance"]
  launch_template {
    id      = aws_launch_template.web_lt.id
    version = aws_launch_template.web_lt.latest_version
  }
  min_size = var.min_servers
  max_size = var.max_servers
 
  lifecycle {
    create_before_destroy = true
  }
}
resource "aws_autoscaling_attachment" "application_asg_attachment" {
  autoscaling_group_name = aws_autoscaling_group.web_asg.name
  lb_target_group_arn    = var.alb_target_group_arn
}