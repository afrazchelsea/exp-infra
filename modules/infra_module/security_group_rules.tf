data "external" "self_ip" {
  program = ["/bin/bash", "${path.module}/scripts/self_ip.sh"]
}

data "aws_instance" "cicd_instance_data" {
  instance_id = module.cicd_instance.instance_id
}

locals {
  cicd_instance_private_ip = data.aws_instance.cicd_instance_data.private_ip
}

resource "aws_security_group_rule" "cicd_egress" {
  description       = "CICD Instance egress rule"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.cicd_instance.sg_id
}

resource "aws_security_group_rule" "cicd_ingress_http" {
  description       = "CICD Ingress rule for HTTP"
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = [format("%s/%s", data.external.self_ip.result["internet_ip"], 32)]
  security_group_id = module.cicd_instance.sg_id
}

resource "aws_security_group_rule" "cicd_ingress_ssh" {
  description       = "CICD Ingress rule for SSH"
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = [format("%s/%s", data.external.self_ip.result["internet_ip"], 32)]
  security_group_id = module.cicd_instance.sg_id
}

resource "aws_security_group_rule" "cicd_ingress_tomcat" {
  description       = "CICD Instance Ingress rule for 8080"
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  cidr_blocks       = [format("%s/%s", data.external.self_ip.result["internet_ip"], 32)]
  security_group_id = module.cicd_instance.sg_id
}

resource "aws_security_group_rule" "host_egress" {
  description       = "Host Instance egress rule"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.host_instance.sg_id
}

resource "aws_security_group_rule" "host_ingress_ssh" {
  description       = "Ingress rule for CICD instance to ssh into the Host instance"
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["${local.cicd_instance_private_ip}/32"]
  security_group_id = module.host_instance.sg_id
}

resource "aws_security_group_rule" "host_ingress_http" {
  description       = "For host to receive traffic from CICD Instance"
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  source_security_group_id = module.load_balancer.lb_sg_id
  security_group_id = module.host_instance.sg_id
}

resource "aws_security_group_rule" "host_ingress_tomcat" {
  description       = "For host to receive traffic from CICD Instance"
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  source_security_group_id = module.load_balancer.lb_sg_id
  security_group_id = module.host_instance.sg_id
}

resource "aws_security_group_rule" "alb_ingress_http" {
  description       = "ALB Ingress rule for HTTP"
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.load_balancer.lb_sg_id
}

resource "aws_security_group_rule" "alb_egress" {
  description       = "ALB egress rule"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.load_balancer.lb_sg_id
}
