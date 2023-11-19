variable "template_name" {
    type = string
}
variable "image_id" {
    type = string
}
variable "instance_type" {
    type = string
}
variable "asg_subnets" {
    type = list
}
variable "min_servers" {
    type = string
}
variable "max_servers" {
    type = string
}
variable "alb_target_group_arn"{
    type= string
}
variable "sg_id"{
    
}