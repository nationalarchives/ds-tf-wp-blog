resource "aws_route53_zone" "dev_blog" {
    name = "${var.environment}-blog.nationalarchives.gov.uk"

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
  name    = "${var.environment}-blog.nationalarchives.gov.uk"
  type    = "A"
  ttl     = "300"
  records = [aws_lb.public_lb.name]
}
