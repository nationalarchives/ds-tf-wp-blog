resource "aws_route53_record" "db" {
    zone_id = var.route53_local_zone_id
    name    = "db.${var.service}wp.${var.environment}.local"
    type    = "CNAME"
    ttl     = "300"
    records = [
        aws_db_instance.wp_db_main.address
    ]
}

resource "aws_route53_record" "db_temp" {
    zone_id = var.route53_local_zone_id
    name    = "db_temp.${var.service}wp.${var.environment}.local"
    type    = "CNAME"
    ttl     = "300"
    records = [
        aws_db_instance.wp_db_main_10_6.address
    ]
}

