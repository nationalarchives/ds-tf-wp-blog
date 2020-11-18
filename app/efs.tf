resource "aws_efs_file_system" "wp_efs" {
    creation_token = "${var.service}-wp-${var.environment}-efs"

    tags = {
        Name = "${var.service}-wp-${var.environment}-efs"
        Service = var.service
        Environment = var.environment
        Terraform = "true"
    }
}

resource "aws_efs_mount_target" "efs_private_a" {
    file_system_id = aws_efs_file_system.wp_efs.id
    security_groups = [
        aws_security_group.wp_efs_access.id]
    subnet_id = var.private_subnet_a_id
}

resource "aws_efs_mount_target" "efs_private_b" {
    file_system_id = aws_efs_file_system.wp_efs.id
    security_groups = [
        aws_security_group.wp_efs_access.id]
    subnet_id = var.private_subnet_b_id
}
