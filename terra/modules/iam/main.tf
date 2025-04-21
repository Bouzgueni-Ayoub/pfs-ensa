resource "aws_iam_role" "wireguard_role" {
  name = "wireguard-ec2-role"

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
resource "aws_iam_role" "ansible_role" {
  name = "ansible-ec2-role"

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
resource "aws_iam_instance_profile" "wireguard_profile" {
  name = "wireguard-ec2-instance-profile"
  role = aws_iam_role.wireguard_role.name
}

resource "aws_iam_instance_profile" "ansible_profile" {
  name = "ansible-ec2-instance-profile"
  role = aws_iam_role.ansible_role.name
}

resource "aws_iam_policy" "describe_ec2_policy" {
  name = "DescribeEC2InstancesPolicy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ec2:DescribeInstances"
        ],
        Resource = "*"
      }
    ]
  })
}


resource "aws_iam_policy" "s3_access_policy_wireguard" {
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
  name = "S3ListPolicy"

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
# Policy for Ansible
resource "aws_iam_role_policy_attachment" "attach_s3_policy_ansible" {
  role       = aws_iam_role.ansible_role.name
  policy_arn = aws_iam_policy.s3_access_policy_ansible.arn
}
resource "aws_iam_role_policy_attachment" "attach_s3_list_bucket_ansible" {
  role       = aws_iam_role.ansible_role.name
  policy_arn = aws_iam_policy.s3_list_buckets.arn
}
resource "aws_iam_role_policy_attachment" "attach_describe_ec2_ansible" {
  role       = aws_iam_role.ansible_role.name
  policy_arn = aws_iam_policy.describe_ec2_policy.arn
}

# Policy for wireguard server
resource "aws_iam_role_policy_attachment" "attach_s3_policy_wireguard" {
  role       = aws_iam_role.wireguard_role.name
  policy_arn = aws_iam_policy.s3_access_policy_wireguard.arn
}
resource "aws_iam_role_policy_attachment" "attach_s3_list_bucket_wireguard" {
  role       = aws_iam_role.wireguard_role.name
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

resource "aws_iam_role_policy_attachment" "attach_cloudwatch_wireguard" {
  role       = aws_iam_role.wireguard_role.name
  policy_arn = aws_iam_policy.cloudwatch_logs_policy.arn
}
resource "aws_iam_role_policy_attachment" "attach_cloudwatch_ansible" {
  role       = aws_iam_role.ansible_role.name
  policy_arn = aws_iam_policy.cloudwatch_logs_policy.arn
}
