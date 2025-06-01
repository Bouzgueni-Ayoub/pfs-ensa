#!/bin/bash

set -e


# Update and install required dependencies
apt update -y
apt install -y unzip curl wget
sudo apt install -y jq
apt-get install -y wget tar

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

#for bucket in $(aws s3api list-buckets --query "Buckets[].Name" --output text); do
#  # Try to get tags for the bucket
#  tags=$(aws s3api get-bucket-tagging --bucket "$bucket" --query "TagSet" --output json 2>/dev/null)
#
#  # If tags exist and include our desired tag
#  if echo "$tags" | jq -e '.[] | select(.Key=="Name" and .Value=="WireGuard Configs")' >/dev/null; then
#    export BUCKET_NAME=$bucket
#    echo "✅ Found bucket: $BUCKET_NAME"
#    break
#  fi
#done
#
## Wait for folder and upload to S3
#for i in {1..15}; do
#  if [ -d "/home/ubuntu/ansible/clients/" ] && [ "$(ls -A "/home/ubuntu/ansible/clients/")" ]; then
#    echo "✅ Found client config folder, uploading to S3..."
#    bucket="$BUCKET_NAME"
#    aws s3 cp "/home/ubuntu/ansible/clients/" "s3://$bucket/clients/" --recursive
#
#    break
#  else
#    echo "⏳ Folder not ready yet, retrying in 5 seconds..."
#    sleep 5
#  fi
#done




#Installing Node Exporter on WireGuard EC2

# Download and install Node Exporter
cd /opt
wget https://github.com/prometheus/node_exporter/releases/latest/download/node_exporter-1.8.1.linux-amd64.tar.gz
tar xvf node_exporter-1.8.1.linux-amd64.tar.gz
mv node_exporter-1.8.1.linux-amd64/node_exporter /usr/local/bin/

# Create systemd service file
cat <<EOF > /etc/systemd/system/node_exporter.service
[Unit]
Description=Prometheus Node Exporter
After=network.target

[Service]
User=nobody
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=default.target
EOF

# Start and enable the service
systemctl daemon-reexec
systemctl enable node_exporter
systemctl start node_exporter
