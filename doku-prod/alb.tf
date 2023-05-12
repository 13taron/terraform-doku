resource "aws_lb" "alb" {
  name               = var.name_alb
  internal           = false
  load_balancer_type = "application"
  subnets            = module.vpc.public_subnets
  security_groups    = [aws_security_group.lb_sg.id]
  tags = {
    Name = "my-alb"
  }
}

resource "aws_lb_target_group" "target_group" {
  name_prefix      = var.name_prefix_tg
  port             = 80
  protocol         = "HTTP"
  vpc_id           = module.vpc.vpc_id
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 5
    interval            = 30
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
  }
  tags = {
    Name = "my-target-group"
  }
}

resource "aws_lb_target_group_attachment" "first_ec2" {
  target_group_arn = aws_lb_target_group.target_group.arn
  target_id        = module.ec2-instance1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "second_ec2" {
  target_group_arn = aws_lb_target_group.target_group.arn
  target_id        = module.ec2-instance2.id
  port             = 80
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn
  }
}
resource  "aws_security_group"  "lb_sg" {
  name        = "alb_security_group"
  description = "Allow  HTTP"
  vpc_id      = module.vpc.vpc_id

  ingress {
  description = "HTTP from VPC"
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
  }
}