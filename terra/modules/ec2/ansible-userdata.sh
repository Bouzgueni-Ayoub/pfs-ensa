#!/bin/bash

# Update and install required dependencies
apt update -y
apt install -y unzip curl wget
sudo apt install -y jq

# Install AWS CLI v2 without modifying the $PATH explicitly
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install


# Install Ansible
add-apt-repository --yes --update ppa:ansible/ansible
apt install -y ansible
mkdir -p /home/ubuntu/ansible
cp /tmp/ansible/* /home/ubuntu/ansible/
chown -R ubuntu:ubuntu /home/ubuntu/ansible

# Install CloudWatch Agent
wget https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
dpkg -i amazon-cloudwatch-agent.deb

# Create CloudWatch config
cat > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json <<EOF
{
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/syslog",
            "log_group_name": "/ec2/ansible/syslog",
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

# Check if AWS CLI is installed
aws --version

# Find the bucket name by tag value "Ansible files"
BUCKET_NAME=$(aws s3api list-buckets --query "Buckets[].Name" --output text | tr '\t' '\n' | while read bucket; do
  TAGS=$(aws s3api get-bucket-tagging --bucket "$bucket" --query "TagSet" --output json 2>/dev/null)
  echo "$TAGS" | jq -e '.[] | select(.Key=="Name" and .Value=="Ansible files")' >/dev/null && echo "$bucket" && break
done)

# Exit if no bucket found
if [ -z "$BUCKET_NAME" ]; then
  echo "No bucket found with tag 'Ansible files'" >&2
  exit 1
fi

echo "Found bucket: $BUCKET_NAME"

# Create target folder
mkdir -p /opt/ansible

# Sync contents from the bucket to the folder
aws s3 sync "s3://$BUCKET_NAME/ansible" /opt/ansible

# Optional: make scripts or playbooks executable
chmod +x /opt/ansible/*.yml