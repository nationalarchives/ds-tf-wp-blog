variable "environment" {}

variable "service" {}

variable "cost_centre" {}

variable "owner" {}

variable "created_by" {}

variable "vpc_id" {}

variable "ami_id" {}

variable "blog_app_sg_id" {}

variable "instance_type" {
    default = "t2.micro"
}

variable "public_ip" {
    default = false
}

variable "key_name" {}

variable "subnet_id" {}

variable "volume_size" {}

variable "blog_db_name" {}

variable "blog_db_username" {}

variable "blog_db_password" {}

variable "blog_domain_name" {}

variable "deployment_s3_bucket" {}

variable "ses_username" {}

variable "ses_password" {}

variable "ses_host" {}

variable "ses_port" {}

variable "ses_secure" {}

variable "ses_from_email" {}

variable "ses_from_name" {}

variable "cdn_bucket_name" {}

variable "cdn_aws_region" {}

variable "cdn_cloudfront_url" {}

variable "cdn_dir" {}
