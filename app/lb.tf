# Public Load Balancer
resource "aws_lb" "public_lb" {
    name        = "${var.service}-wp-${var.environment}-lb"
    internal           = false
    load_balancer_type = "application"

    security_groups = [
        aws_security_group.wp_public_access.id]

    subnets = [
        var.public_subnet_a_id,
        var.public_subnet_b_id
    ]

    tags = {
        Service         = var.service
        Environment     = var.environment
        CostCentre      = var.cost_centre
        Owner           = var.owner
        CreatedBy       = var.created_by
        Terraform       = true
    }
}

resource "aws_lb_target_group" "wp" {
    name     = "${var.service}-wp-${var.environment}-lb-target"
    port     = 80
    protocol = "HTTP"
    vpc_id   = var.vpc_id

    health_check {
        interval            = 30
        path                = "/healthcheck.html"
        port                = "traffic-port"
        timeout             = 5
        healthy_threshold   = 2
        unhealthy_threshold = 2
        matcher             = "200"
    }

    tags = {
        Service         = var.service
        Environment     = var.environment
        CostCentre      = var.cost_centre
        Owner           = var.owner
        CreatedBy       = var.created_by
        Terraform       = true
    }
}

resource "aws_lb_listener" "public_http_lb_listener" {
    default_action {
        target_group_arn = aws_lb_target_group.wp.arn
        type             = "forward"
    }
    protocol          = "HTTP"
    load_balancer_arn = aws_lb.public_lb.arn
    port              = 80
}

resource "aws_lb_listener" "public_https_lb_listener" {
    default_action {
        target_group_arn = aws_lb_target_group.wp.arn
        type             = "forward"
    }
    protocol          = "HTTPS"
    load_balancer_arn = aws_lb.public_lb.arn
    port              = 443
    certificate_arn   = var.public_ssl_cert_arn
    ssl_policy        = "ELBSecurityPolicy-2016-08"
}
