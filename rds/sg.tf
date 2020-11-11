#
#
# WordPress Security Group database access
resource "aws_security_group" "wp_db_access" {
    name        = "${var.service}-wp-${var.environment}-db-sg"
    description = "DB security group"
    vpc_id      = var.vpc_id

    tags = {
        Name            = "${var.service}-wp-${var.environment}-db-sg"
        Service         = var.service
        Environment     = var.environment
        CostCentre      = var.cost_centre
        Owner           = var.owner
        CreatedBy       = var.created_by
        Terraform       = true
    }
}

resource "aws_security_group_rule" "wp_db_ingress" {
    from_port                = 3306
    protocol                 = "tcp"
    security_group_id        = aws_security_group.wp_db_access.id
    to_port                  = 3306
    type                     = "ingress"
    source_security_group_id = var.wp_app_access_sg_id
}

resource "aws_security_group_rule" "wp_db_egress" {
    security_group_id = aws_security_group.wp_db_access.id
    type              = "egress"
    from_port         = 0
    to_port           = 0
    protocol          = "-1"
    cidr_blocks       = [
        var.everyone]
}
