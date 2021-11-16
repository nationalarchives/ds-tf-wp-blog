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
    }
}