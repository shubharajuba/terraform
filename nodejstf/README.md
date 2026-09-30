# Node.js EC2 Terraform Deployment

This Terraform configuration creates an AWS VPC with a public subnet and launches a `t3.micro` EC2 instance for a Node.js application. The instance bootstrap script installs Node.js 22 and PM2, then clones and starts the application.

## Prerequisites

- Terraform 1.6 or later
- AWS CLI credentials configured for an AWS account, such as through `aws configure`, an AWS profile, or environment variables
- An AWS identity permitted to create VPC, subnet, routing, security group, and EC2 resources
- An Ubuntu 24.04 AMI ID for the selected region
- An existing EC2 key pair in the selected region
- The Node.js application's GitHub repository URL

## Configure

Before running Terraform, edit `userdata.sh` and replace the placeholder repository URL with the Git URL of your Node.js application. The repository must contain a `package.json` with a `start` script. Otherwise, instance setup will fail when it attempts to clone or start the app.

Create a `terraform.tfvars` file in this directory with the required values:

```hcl
ami_id           = "ami-0123456789abcdef0"
key_name         = "my-ec2-key"
ssh_allowed_cidr = "203.0.113.10/32"
```

Use a real Ubuntu 24.04 AMI ID and key pair for the configured region. Set `ssh_allowed_cidr` to your trusted public IP in CIDR notation, typically `/32`; do not use `0.0.0.0/0` for SSH access.

The defaults are region `ap-south-1` and availability zone `ap-south-1a`. If you change the region, choose an availability zone and AMI from that same region. Do not commit `terraform.tfvars` if it contains private or environment-specific values.

## Deploy

Run these commands from this directory:

```sh
terraform init
terraform fmt -check
terraform validate
terraform plan -out=tfplan
terraform apply tfplan
```

Review the plan before applying. Terraform will create billable AWS resources. To apply interactively without saving a plan file, use `terraform apply` instead.

## Connect and test

After the apply completes, Terraform prints the instance ID, public IP, public DNS name, application URL, and health-check URL:

```sh
terraform output
```

The application URLs use port `3000`. Instance startup can take several minutes; check the EC2 system log or cloud-init log if the application is not ready. To connect over SSH, use the matching private key for the configured EC2 key pair:

```sh
ssh -i /path/to/private-key.pem ubuntu@$(terraform output -raw public_ip)
```

Keep the private key secure and restrict its local file permissions. The security group currently allows application traffic on port `3000` from anywhere; restrict that ingress CIDR in `main.tf` if the application should not be public.

## Clean up

To remove the resources managed by this configuration:

```sh
terraform destroy
```

Review the destroy plan and confirm before proceeding. Terraform state may contain infrastructure details, so keep local state files and backups private.

## Resources created

- VPC, public subnet, internet gateway, route table, and route table association
- Security group allowing SSH from `ssh_allowed_cidr`, HTTP application traffic on port `3000`, and outbound traffic
- Ubuntu EC2 instance (`t3.micro`) with an encrypted 20 GB `gp3` root volume and an automatically assigned public IPv4 address