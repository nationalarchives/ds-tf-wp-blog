resource "aws_iam_role" "blog_role" {
    name               = "${var.service}-wp-${var.environment}-assume-role"
    assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": "WPAssumeRole"
        }
    ]
}
EOF
}

resource "aws_iam_policy" "blog_cdn_s3_access" {
    name        = "${var.service}-wp-${var.environment}-cdn-s3bucket-policy"
    description = "WP blog access to CDN"

    policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetBucketLocation",
        "s3:ListBucket"
      ],
     "Resource": [
        "${var.cdn_s3_bucket_arn}"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:GetObject",
        "s3:DeleteObject",
        "s3:PutObjectAcl"
      ],
      "Resource": [
         "${var.cdn_s3_bucket_arn}/*"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "s3_instance_role_policy" {
    policy_arn = aws_iam_policy.blog_cdn_s3_access.arn
    role       = aws_iam_role.blog_role.id
}

resource "aws_iam_role_policy_attachment" "smm_ec2_role_policy" {
    policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
    role       = aws_iam_role.blog_role.id
}

resource "aws_iam_instance_profile" "blog" {
    name = "${var.service}-wp-${var.environment}-iam-instance-profile"
    path = "/"
    role = aws_iam_role.blog_role.name
}