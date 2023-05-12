
# DokuWiki Installation using Terraform

This project provides Terraform code to easily install DokuWiki, a popular open-source wiki software, on Amazon Web Services (AWS). The code is designed to be easy to understand and maintain, and it can be customized and reused for your own projects.

## Installation Steps

1. Create VPC with Public and Private Subnets:
   - The Terraform code will create a Virtual Private Cloud (VPC) with both public and private subnets.
   - The public subnets will be used for the EC2 instances and the Application Load Balancer (ALB).
   - The private subnets will be used for the shared storage using Amazon EFS.

2. Create EC2 Instances:
   - The Terraform code will create two EC2 instances.
   - Each instance will have a user data script that will automatically download and install DokuWiki.
   - You can refer to the `doc-examples/dokureadme.txt` file for more details on how to install dokuwiki manually.
3. Create Security Group for EC2 Instances:
   - The Terraform code will create a security group for the EC2 instances.
   - The security group will allow inbound SSH and HTTP traffic, and allow all outbound traffic.

4. Create Amazon EFS Shared Storage:
   - The Terraform code will create an Amazon EFS file system for shared storage between the instances and the ALB.
   - Each resource (instances and ALB) will have its own security group for access control.

## Usage

1. Clone this repository.

2. Modify the Terraform code as per your requirements. You can customize variables, adjust resource configurations, or add additional resources.

3. Initialize the Terraform project:
   ```bash
   terraform init
   terraform plan
   terraform apply