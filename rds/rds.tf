resource "aws_db_instance" "wp_db_main" {
    name                        = var.wp_db_name
    identifier_prefix           = "${var.service}-wp-ma-"
    allocated_storage           = 5
    storage_type                = "gp2"
    engine                      = "mysql"
    engine_version              = "8.0.17"
    license_model               = "general-public-license"
    instance_class              = var.db_instance_class
    username                    = var.wp_db_username
    password                    = var.wp_db_password
    apply_immediately           = var.db_apply_immediately
    db_subnet_group_name        = var.db_subnet_group_name
    multi_az                    = var.db_multi_az
    vpc_security_group_ids      = [
        aws_security_group.wp_db_access.id]
    parameter_group_name        = var.db_parameter_group_name
    allow_major_version_upgrade = true
    final_snapshot_identifier   = "${var.service}-wp-${var.environment}-final-db-snapshot"
    backup_window               = var.db_backup_window
    backup_retention_period     = var.db_backup_retention_period

    tags = {
        Name            = "${var.service}-wp-${var.environment}-ma"
        Service         = var.service
        Environment     = var.environment
        CostCentre      = var.cost_centre
        Owner           = var.owner
        CreatedBy       = var.created_by
        Terraform       = true
    }
}

resource "aws_db_instance" "wp_db_replica" {
    count                   = var.environment == 'live' ? 1 : 0
    name                    = var.wp_db_name
    identifier_prefix       = "${var.service}-wp-rr-"
    allocated_storage       = 5
    storage_type            = "gp2"
    engine                  = "mysql"
    engine_version          = "8.0.17"
    license_model           = "general-public-license"
    instance_class          = var.db_instance_class
    username                = var.wp_db_username
    password                = var.wp_db_password
    apply_immediately       = var.db_apply_immediately
    replicate_source_db     = aws_db_instance.wp_db_master.identifier
    backup_window           = var.db_backup_window
    backup_retention_period = 1
    skip_final_snapshot     = true

    tags = {
        Name            = "${var.service}-wp-${var.environment}-rr"
        Service         = var.service
        Environment     = var.environment
        CostCentre      = var.cost_centre
        Owner           = var.owner
        CreatedBy       = var.created_by
        Terraform       = true
    }
}

resource "aws_db_parameter_group" "wp_db_parameter_group" {
    name   = "${var.service}-wp-${var.environment}-db-mariadb"
    family = var.wp_db_parameter_group

    parameter {
        name  = "log_bin_trust_function_creators"
        value = "1"
    }
}
