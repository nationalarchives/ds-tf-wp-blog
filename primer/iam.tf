# -----------------------------------------------------------------------------
# IAM instance role and instance profile
# -----------------------------------------------------------------------------
resource "aws_iam_role" "primer" {
    name               = "${var.service}-wp-primer-${var.environment}-assume-role"
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

resource "aws_iam_policy" "wp_deployment_s3" {
    name        = "${var.service}-wp-primer-${var.environment}-s3-policy"
    description = "WP deployment S3 access"

    policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:ListBucket"
      ],
     "Resource": [
        "arn:aws:s3:::${var.deployment_s3_bucket}"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject"
      ],
      "Resource": [
         "arn:aws:s3:::${var.deployment_s3_bucket}/${var.service}/*"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "wp_deployment_s3_policy" {
    policy_arn = aws_iam_policy.wp_deployment_s3.arn
    role       = aws_iam_role.primer.id
}

resource "aws_iam_role_policy_attachment" "smm_ec2_role_policy" {
    policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
    role       = aws_iam_role.primer.id
}

resource "aws_iam_role_policy_attachment" "cloudwatch_agent_role_policy" {
    policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
    role       = aws_iam_role.primer.id
}

resource "aws_iam_role_policy_attachment" "ssmmanaged_role_policy" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    role       = aws_iam_role.primer.id
}

resource "aws_iam_instance_profile" "primer" {
    name = "${var.service}-wp-primer-${var.environment}-iam-instance-profile"
    path = "/"
    role = aws_iam_role.primer.name
}
