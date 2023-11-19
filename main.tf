module "vpc" {
    source         = "./vpc"
    vpc_cidr_range = "10.0.0.0/24"
    dns_hostname   = true
    dns_support    = true 
}
module "private_subnets"{
    source = "./subnet"
    vpc_id = module.vpc.vpc_id
    subnet_cidr_range = ["10.0.0.0/28","10.0.0.64/26"]
    map_public_ip     = [false , false ]
    gateway_id        = module.vpc.gateway_id
    az                = ["me-central-1a","me-central-1b"]

}
module "nat_module"{
    source = "./nat-gw"
    subnet_id  = element(module.public_subnets.*.subnet_id[0], 0)
    table_id = module.private_subnets.table_id
}
module "public_subnets"{
    source = "./subnet"
    vpc_id = module.vpc.vpc_id
    subnet_cidr_range = ["10.0.0.128/26","10.0.0.192/26"]
    az                = ["me-central-1a","me-central-1b"]
    map_public_ip     = [true,true]
    gateway_id        = module.vpc.gateway_id
    count_gw = 1
}
module "zabehaty_lb"{
    source = "./lb"
    alb_name = "zabehaty-lb"
    vpc_id = module.vpc.vpc_id
    sg   = [module.alb_sg.sg_id,module.ssh_alb_sg.sg_id]
    subnet_ids = [module.public_subnets.subnet_id[*]]
    port = 80
    target_type   = "instance"
    cert_arn = "arn:aws:acm:me-central-1:527643879239:certificate/d9c262fa-478e-4dd9-af3b-128ef35cec3a"
}
module "asg"{
  source = "./autoscaling"
  template_name = "zabehaty_template"
  image_id = "ami-02168d82d5c12118f"
  sg_id   = [module.bastion_sg.sg_id,module.http_sg.sg_id]
  instance_type = "c5.large"
  asg_subnets = module.private_subnets.subnet_id
  min_servers = 2
  max_servers = 4
  alb_target_group_arn = module.zabehaty_lb.alb_target_group_arn
}
  module "mysql"{
    source  = "./rds"
    storage = 100
    identifier  = "rds-mysql-web"
    engine  = "mysql"
    engine_version =  "5.7"
    instance_type = "db.t3.large"
    subnet_id  = module.private_subnets.subnet_id
    sg = [module.mysql_sg.sg_id]
  }
module "mysql_sg"{
    source = "./security-group"
    sg_name =  "mysql_sg"
    vpc_id = module.vpc.vpc_id
   ingress = [{
        description = ""
        from_port = 3306
        to_port   = 3306
        protocol  = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }]
    egress = [{
        description = "egres rule"
        from_port  = 0
        to_port  = 0
        protocol   = "-1"
        cidr_blocks =  ["0.0.0.0/0"]
    }]
}

module "bastion_sg"{
    source = "./security-group"
    sg_name =  "bastion_sg"
    vpc_id = module.vpc.vpc_id
   ingress = [{
        description = ""
        from_port = 22
        to_port   = 22
        protocol  = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }]
    egress = [{
        description = "egres rule"
        from_port  = 0
        to_port  = 0
        protocol   = "-1"
        cidr_blocks =  ["0.0.0.0/0"]
    }]
}
module "http_sg"{
    source = "./security-group"
    sg_name =  "http_sg"
    vpc_id = module.vpc.vpc_id
   ingress = [{
        description = ""
        from_port = 80
        to_port   = 80
        protocol  = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }]
    egress = [{
        description = "egres rule"
        from_port  = 0
        to_port  = 0
        protocol   = "-1"
        cidr_blocks =  ["0.0.0.0/0"]
    }]
}

module "alb_sg"{
    source = "./security-group"
    sg_name =  "alb_sg"
    vpc_id = module.vpc.vpc_id
   ingress = [{
        description = ""
        from_port = 80
        to_port   = 80
        protocol  = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }]
    egress = [{
        description = "egres rule"
        from_port  = 80
        to_port  = 80
        protocol   = "tcp"
        cidr_blocks =  ["0.0.0.0/0"]
    }]
}
module "ssh_alb_sg"{
    source = "./security-group"
    sg_name =  "ssh_alb_sg"
    vpc_id = module.vpc.vpc_id
   ingress = [{
        description = ""
        from_port = 443
        to_port   = 443
        protocol  = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }]
    egress = [{
        description = "egres rule"
        from_port  = 443
        to_port  = 443
        protocol   = "tcp"
        cidr_blocks =  ["0.0.0.0/0"]
    }]
}
module "bastion_eip"{
    source = "./eip"
    instance = module.bastion-server.instance_id
}
module "bastion-server"{
    source = "./ec2"
    ami = "ami-02168d82d5c12118f"
    instance_type = "t3.micro"
    subnet_id = module.public_subnets.subnet_id[0]
    sg_id = [module.bastion_sg.sg_id]
}
module "zabehaty-ecr"{
    source = "./ecr"
    ecr_name = "zabehaty-ecr"
}
module "zabehaty_static_s3"{
    source = "./s3"
    bucket_name = "zabehaty-static-s3"
}
