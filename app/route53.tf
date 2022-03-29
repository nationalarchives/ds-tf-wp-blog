resource "aws_route53_zone" "dev_blog" {
    name = var.public_domain_name

    tags = {
        Environment = var.environment
        Owner       = var.owner
        CreatedBy   = var.created_by
        CostCentre  = var.cost_centre
        Service     = var.service
    }
}

resource "aws_route53_record" "dev_blog_a" {
  zone_id = aws_route53_zone.dev_blog.zone_id
  name    = var.public_domain_name
  type    = "A"

  alias {
    name                   = aws_lb.public_lb.dns_name
    zone_id                = aws_lb.public_lb.zone_id
    evaluate_target_health = true
  }
}
