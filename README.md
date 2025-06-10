# Automated WireGuard VPN Infrastructure on AWS

This project automates the provisioning and monitoring of a WireGuard VPN infrastructure using **Terraform**, **Ansible**, and **GitHub Actions** on AWS. It enables secure, scalable VPN access for multiple clients, with automatic generation of client configuration files and real-time monitoring through a Grafana dashboard.

---

## 📦 Features

- 🔐 Automated WireGuard VPN deployment on AWS EC2
- ☁️ Infrastructure-as-Code with Terraform
- 🤖 Configuration management with Ansible
- 📊 Real-time monitoring with Prometheus & Grafana
- 🔁 CI/CD pipeline using GitHub Actions
- 🧾 WireGuard client configuration auto-generation
- 🪣 Storage of client configs in AWS S3

---

## ✅ Prerequisites

Before using this project, make sure you have the following:

### AWS Setup
1. **AWS Account** – You need an active AWS account.
2. **IAM User** – Create an IAM user with programmatic access and the necessary permissions.
3. **Access Keys** – Save the access keys, then set them as GitHub Secrets:
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`

### S3 Bucket
4. Create an S3 bucket (any name you like) and update the `backend` block in `main.tf` (located in the root directory) with your bucket name.

### SSH Access
5. Generate an SSH key pair:
   - Name the private key `main-key`
   - Save the private key as a GitHub Secret named: `SSH_PRIVATE_KEY`

### Client Configuration
6. Depending on the number of clients, follow the format described in `terra/variable-formula.txt`.
7. Encode the final formatted text using **Base64**.
8. Add it as a GitHub Secret named: `CLIENTS`

### Workflow Configuration
9. Go to `.github/workflows/terraform` and **rename or create** a YAML file (e.g., `main.yml`) to define your GitHub Actions workflow.

---

## 🚀 Deployment

Once all the above steps are completed:

- A GitHub Actions workflow will trigger and **provision the entire VPN infrastructure** on AWS.
- WireGuard **client configuration files** will be generated and stored in an S3 bucket starting with the name "wireguard-configs".
  - Files will be in a folder called "clients"
- After the clients connect to the VPN, access the **Grafana dashboard** using:
  - http://<ANSIBLE-CONTROLLER-PUBLIC-IP>:3000
