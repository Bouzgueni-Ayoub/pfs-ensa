resource "aws_iam_role" "ec2_role" {
  name = "ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}
resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "wireguard-ec2-instance-profile"
  role = aws_iam_role.ec2_role.name
}

resource "aws_iam_policy" "s3_access_policy" {
  name = "WireguardS3AccessPolicy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:*"
        ],
        Resource = "${var.s3_bucket_arn_wireguard}/*"
      }
    ]
  })
}

resource "aws_iam_policy" "s3_access_policy_ansible" {
  name = "AnsiblePolicy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:*"
        ],
        Resource = "${var.s3_bucket_arn_ansible_files}/*"
      }
    ]
  })
}
resource "aws_iam_policy" "s3_list_buckets" {
  name = "AnsiblePolicy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:*"
        ],
        Resource = "*"
      }
    ]
  })
}
resource "aws_iam_role_policy_attachment" "attach_s3_policy" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.s3_access_policy.arn
}
resource "aws_iam_role_policy_attachment" "attach_s3_policy_ansible" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.s3_access_policy_ansible.arn
}
resource "aws_iam_role_policy_attachment" "attach_s3_list_bucket" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.s3_list_buckets.arn
}
resource "aws_iam_policy" "cloudwatch_logs_policy" {
  name = "AllowEC2CloudWatchLogging"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:PutLogEvents",
          "logs:CreateLogStream",
          "logs:CreateLogGroup",
          "logs:DescribeLogStreams"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_cloudwatch" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.cloudwatch_logs_policy.arn
}
