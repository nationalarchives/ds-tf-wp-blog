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

variable "cdn_s3_bucket_arn" {}

variable "everyone" {}

variable "deployment_s3_bucket" {}

variable "efs_backup_schedule" {}

variable "efs_backup_start_window" {}

variable "efs_backup_completion_window" {}

variable "efs_backup_cold_storage_after" {}

variable "efs_backup_delete_after" {}

variable "efs_backup_kms_key_arn" {}
