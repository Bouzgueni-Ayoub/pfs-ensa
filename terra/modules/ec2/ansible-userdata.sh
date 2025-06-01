#!/bin/bash

set -e


# Update and install required dependencies
apt update -y
apt install -y unzip curl wget
sudo apt install -y jq
apt-get install -y wget tar


# Install AWS CLI v2 without modifying the $PATH explicitly
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install


# Install Ansible
add-apt-repository --yes --update ppa:ansible/ansible
apt install -y ansible



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

#!/bin/bash

echo "🔍 Searching for S3 bucket tagged as 'Ansible files'..."

for bucket in $(aws s3api list-buckets --query "Buckets[].Name" --output text); do
  # Try to get tags for the bucket
  tags=$(aws s3api get-bucket-tagging --bucket "$bucket" --query "TagSet" --output json 2>/dev/null)

  # If tags exist and include our desired tag
  if echo "$tags" | jq -e '.[] | select(.Key=="Name" and .Value=="Ansible files")' >/dev/null; then
    BUCKET_NAME=$bucket
    echo "✅ Found bucket: $BUCKET_NAME"
    break
  fi
done

if [ -z "$BUCKET_NAME" ]; then
  echo "❌ No matching bucket found. Exiting."
  exit 1
fi

echo "📥 Syncing Ansible files from bucket..."
aws s3 sync s3://$BUCKET_NAME /home/ubuntu


chown -R ubuntu:ubuntu /home/ubuntu


# Optional: make scripts or playbooks executable
chmod +x /opt/ansible/*.yml

# Wait until the main-key.pem file exists before chmod
for i in {1..10}; do
  if [ -f /home/ubuntu/ansible/main-key.pem ]; then
    echo "✅ Found main-key.pem, setting permissions..."
    mv /home/ubuntu/ansible/main-key.pem /home/ubuntu/.ssh/
    chown ubuntu:ubuntu /home/ubuntu/.ssh/main-key.pem
    chmod 600 /home/ubuntu/.ssh/main-key.pem

    break
  else
    echo "⏳ main-key.pem not found yet, retrying in 5 seconds..."
    sleep 5
  fi
done

# Final check if after all retries the file still doesn't exist
if [ ! -f /home/ubuntu/ansible/main-key.pem ]; then
  echo "❌ main-key.pem not found after waiting. Skipping chmod."
fi
cd /home/ubuntu/ansible
ansible-playbook -i inventory.ini wireguard-install.yml -u ubuntu




#Installation of Promatieus

# Create user and directory
useradd --no-create-home --shell /bin/false prometheus
mkdir -p /etc/prometheus /var/lib/prometheus

# Download Prometheus
cd /opt
wget https://github.com/prometheus/prometheus/releases/latest/download/prometheus-2.52.0.linux-amd64.tar.gz
tar xvf prometheus-2.52.0.linux-amd64.tar.gz
cd prometheus-2.52.0.linux-amd64

# Move binaries
cp prometheus promtool /usr/local/bin/

# Move config and consoles
cp -r consoles/ console_libraries/ /etc/prometheus/

# Write Prometheus config
cat <<EOF > /etc/prometheus/prometheus.yml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'wireguard-node'
    static_configs:
      - targets: ['10.0.1.100:9100']
EOF

# Set permissions
chown -R prometheus:prometheus /etc/prometheus /var/lib/prometheus

# Create systemd service
cat <<EOF > /etc/systemd/system/prometheus.service
[Unit]
Description=Prometheus Monitoring
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus \\
  --config.file=/etc/prometheus/prometheus.yml \\
  --storage.tsdb.path=/var/lib/prometheus \\
  --web.console.templates=/etc/prometheus/consoles \\
  --web.console.libraries=/etc/prometheus/console_libraries

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd and start service
systemctl daemon-reexec
systemctl enable prometheus
systemctl start prometheus



#Intallation of Grafana

# Add Grafana APT repo
sudo apt-get install -y software-properties-common
sudo add-apt-repository "deb https://packages.grafana.com/oss/deb stable main"

# Add repo key
sudo apt-get install -y gnupg2
wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -

# Update and install
sudo apt-get update
sudo apt-get install grafana -
sudo systemctl daemon-reexec
sudo systemctl start grafana-server
sudo systemctl enable grafana-server
