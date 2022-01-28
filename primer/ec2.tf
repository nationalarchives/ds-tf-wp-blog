resource "aws_instance" "wp_primer" {
    ami                         = var.ami_id
    associate_public_ip_address = var.public_ip
    instance_type               = var.instance_type
    key_name                    = var.key_name
    subnet_id                   = var.subnet_id
    iam_instance_profile        = aws_iam_instance_profile.primer.name
    vpc_security_group_ids      = [
        var.blog_app_sg_id
    ]

    root_block_device {
        volume_size = var.volume_size
        encrypted   = false
    }
    
    user_data            = data.template_file.ec2_user_data.rendered

    tags = {
        Name            = "${var.service}-wp-primer-${var.environment}"
        Service         = var.service
        Environment     = var.environment
        CostCentre      = var.cost_centre
        Owner           = var.owner
        CreatedBy       = var.created_by
        Terraform       = true
    }
}

data "template_file" "ec2_user_data" {
    template = file("${path.module}/scripts/userdata.sh")

    vars = {
        service              = var.service
        environment          = var.environment
        db_host              = "db.${var.service}wp.${var.environment}.local"
        db_name              = var.blog_db_name
        db_user              = var.blog_db_username
        db_pass              = var.blog_db_password
        environment          = var.environment
        domain               = var.blog_domain_name
        ses_user             = var.ses_username
        ses_pass             = var.ses_password
        ses_host             = var.ses_host
        ses_port             = var.ses_port
        ses_secure           = var.ses_secure
        ses_from_email       = var.ses_from_email
        ses_from_name        = var.ses_from_name
        cdn_bucket_name      = var.cdn_bucket_name
        cdn_aws_region       = var.cdn_aws_region
        cdn_cloudfront_url   = var.cdn_cloudfront_url
        cdn_dir              = var.cdn_dir
        deployment_s3_bucket = var.deployment_s3_bucket
    }
}
