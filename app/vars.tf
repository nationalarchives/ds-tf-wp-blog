variable "environment" {}

variable "service" {}

variable "cost_centre" {}

variable "owner" {}

variable "created_by" {}

variable "vpc_id" {}

variable "public_subnet_a_id" {}

variable "public_subnet_b_id" {}

variable "private_subnet_a_id" {}

variable "private_subnet_b_id" {}

variable "patch_group_name" {}

variable "asg_max_size" {}

variable "asg_min_size" {}

variable "asg_desired_capacity" {}

variable "asg_health_check_grace_period" {}

variable "asg_health_check_type" {}

variable "public_ssl_cert_arn" {}

variable "ami_id" {}

variable "instance_type" {}

variable "key_name" {}

variable "efs_mount_dir" {}

variable "wp_db_name" {}

variable "wp_db_username" {}

variable "wp_db_password" {}

variable "wp_domain_name" {}

variable "cdn_bucket_name" {}

variable "cdn_aws_region" {}

variable "cdn_cloudfront_url" {}

variable "cdn_s3_bucket_arn" {}

variable "cdn_dir" {}

variable "wpms_smtp_password" {}

variable "everyone" {}

variable "ses_username" {}

variable "ses_password" {}

variable "ses_host" {}

variable "ses_port" {}

variable "ses_secure" {}

variable "ses_from_email" {}

variable "ses_from_name" {}
