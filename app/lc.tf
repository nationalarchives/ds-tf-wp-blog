# WordPress autoscaling group and launch config
resource "aws_launch_configuration" "wp_launch_config" {
    name_prefix          = "${var.service}wp"
    image_id             = var.ami_id
    instance_type        = var.instance_type
    iam_instance_profile = aws_iam_instance_profile.blog.name
    user_data            = data.template_file.ec2_userdata.rendered
    key_name             = var.key_name

    security_groups = [
        aws_security_group.wp_app_access.id]

    root_block_device {
        volume_size = 100
        encrypted = true
    }

    lifecycle {
        create_before_destroy = true
    }
}

data "template_file" "ec2_userdata" {
    template = file("${path.module}/scripts/userdata.sh")

    vars = {
        mount_target       = aws_efs_file_system.wp_efs.dns_name
        mount_dir          = var.efs_mount_dir
        db_host            = "db.${var.service}wp.${var.environment}.local"
        db_name            = var.wp_db_name
        db_user            = var.wp_db_username
        db_pass            = var.wp_db_password
        service            = var.service
        environment        = var.environment
        domain             = var.wp_domain_name
        cdn_bucket_name    = var.cdn_bucket_name
        cdn_aws_region     = var.cdn_aws_region
        cdn_cloudfront_url = var.cdn_cloudfront_url
        cdn_dir            = var.cdn_dir
        ses_user           = var.ses_username
        ses_pass           = var.ses_password
        ses_host           = var.ses_host
        ses_port           = var.ses_port
        ses_secure         = var.ses_secure
        ses_from_email     = var.ses_from_email
        ses_from_name      = var.ses_from_name
    }
}