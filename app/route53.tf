resource "aws_route53_record" "db" {
    zone_id = var.route53_local_zone_id
    name    = "db.${var.service}wp.${var.environment}.local"
    type    = "CNAME"
    ttl     = "300"
    records = [
        var.wp_db_instance_address
    ]
}
