#!/bin/bash

# Update and install required dependencies
apt update -y
apt install -y unzip curl wget

# Install AWS CLI v2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install

# Install CloudWatch Agent
wget https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
dpkg -i amazon-cloudwatch-agent.deb

# Create CloudWatch Agent config file
cat > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json <<EOF
{
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/syslog",
            "log_group_name": "/ec2/wireguard/syslog",
            "log_stream_name": "{instance_id}"
          }
        ]
      }
    }
  }
}
EOF

# Set proper permissions for the config file
chmod 644 /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json

# Start CloudWatch Agent
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json -s

for bucket in $(aws s3api list-buckets --query "Buckets[].Name" --output text); do
  # Try to get tags for the bucket
  tags=$(aws s3api get-bucket-tagging --bucket "$bucket" --query "TagSet" --output json 2>/dev/null)

  # If tags exist and include our desired tag
  if echo "$tags" | jq -e '.[] | select(.Key=="Name" and .Value=="WireGuard Configs")' >/dev/null; then
    export BUCKET_NAME=$bucket
    echo "✅ Found bucket: $BUCKET_NAME"
    break
  fi
done
SRC_DIR="/home/ubuntu/ansible/clients"
# making sure aws cli is available
for i in {1..10}; do
  if command -v aws >/dev/null 2>&1; then
    echo "✅ AWS CLI is available."
    break
  else
    echo "⏳ Waiting for AWS CLI to become available..."
    sleep 5
  fi
done

# Wait for folder and upload to S3
for i in {1..10}; do
  if [ -d "$SRC_DIR" ] && [ "$(ls -A "$SRC_DIR")" ]; then
    echo "✅ Found client config folder, uploading to S3..."
    sudo aws s3 cp "$SRC_DIR/" "s3://$BUCKET_NAME/clients/" --recursive
    break
  else
    echo "⏳ Folder not ready yet, retrying in 5 seconds..."
    sleep 5
  fi
done