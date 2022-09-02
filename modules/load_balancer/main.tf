resource "aws_lb" "alb" {
  name               = "${var.env}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id]
  subnets            = var.alb_subnets
}

resource "aws_security_group" "lb_sg" {
  name        = "${var.env}-alb-sg"
  description = "Security group created for ${var.env} ALB"
  vpc_id      = var.vpc_id
}

resource "aws_lb_target_group" "alb_tg" {
  name     =  "${var.env}-alb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
}

resource "aws_lb_target_group_attachment" "alb_tg_attach_instances" {
  count                   = length(var.targets)
  target_group_arn = aws_lb_target_group.alb_tg.arn
  target_id        = element(var.targets, count.index)
  port             = 8080
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_tg.arn
  }
}
