# Three Tier Web Application Architecture Using Terraform

This project delivers an automated, highly available, and secure three-tier web application architecture on AWS using Terraform to ensure consistent, repeatable, and scalable infrastructure deployments. The architecture isolates workloads into specialized logical layers across multiple Availability Zones (AZs) to achieve maximum fault tolerance and minimize the blast radius of potential security incidents.

![alt text](three-tier-web-app-architecture.webp)

## Prerequisites:
You must have these installed on your local machine
1. [**AWS CLI**](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html)🔗
2. [**Terraform**](https://developer.hashicorp.com/terraform/install)🔗

## Create the IAM User
1. Log in to the **AWS Management Console** as an administrator.
2. Go to **IAM** (Identify and Access Management) and select **IAM Users**.
3. Click **Create User**
4. Enter a name: `solution-architect` and click **Next**
    - Leave the checkbox for "Provide user access to the AWS Management Console" unchecked since Terraform only requires programmatic CLI access
5. On the **Set permissions** page, select **Attach policies directly**.
6. Search for and check **AdministratorAccess**.
7. Click **Next** at the bottom of the page.

## Generate Access Keys
1. Click your new created user `solution-architect`
2. Select the **Security credentials** tab.
3. Click **Create access key**.
4. Select **Command Line Interface (CLI)**.
5. Check the confirmation box indicating you understand the recommendations, and click **Next**.
6. Add a description tag, such as `Terraform Deployment Key`, and click **Create access key**
7. Click **Download .csv file** to save these keys to your local machine.

## Configure the Credentials on Local Machine
To allow Terraform to securely read these keys without hardcoding them into your .tf files, configure them as local environment variables or inside the AWS CLI.

**Option A: Using the AWS CLI (Recommended)**
<br>
If you have the AWS CLI installed, run this command in your terminal and paste the keys from your downloaded .csv file when prompted: 
`aws configure`
- **AWS Access Key ID**: `[Paste your Access Key ID]`
- **AWS Secret Access Key**: `[Paste your Secret Access Key]`
- **Default region name**: `ap-southeast-1` (or your preferred region)
- **Default output format**: `json`

**Option B: Using Environment Variables**
<br>
Alternatively, you can export the keys directly inside your active terminal session before running Terraform commands:
```
export AWS_ACCESS_KEY_ID="your_access_key_id_here"
export AWS_SECRET_ACCESS_KEY="your_secret_access_key_here"
export AWS_DEFAULT_REGION="ap-southeast-1
```
Once configured, verify your setup by running terraform plan in your project folder to ensure Terraform connects to AWS successfully

## Terraform

The infrastructure is organized into networking, security, presentation, application, and data layers. This separation makes deployments repeatable and isolates each tier according to its role.

### main.tf

The `main.tf` file creates the AWS resources used by the architecture.

#### 1. Networking Layer

The network uses a `/16` VPC across two Availability Zones. Public subnets host the Application Load Balancer and NAT Gateway, private application subnets host EC2 instances, and isolated database subnets host RDS.

```hcl
# VPC
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "three-tier-vpc"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "three-tier-igw"
  }
}
```

The VPC contains the following subnets:

| Tier | Availability Zone | CIDR block | Access |
| --- | --- | --- | --- |
| Public | `ap-southeast-1a` | `10.0.1.0/24` | Internet Gateway |
| Public | `ap-southeast-1b` | `10.0.2.0/24` | Internet Gateway |
| Application | `ap-southeast-1a` | `10.0.11.0/24` | Outbound through NAT Gateway |
| Application | `ap-southeast-1b` | `10.0.12.0/24` | Outbound through NAT Gateway |
| Database | `ap-southeast-1a` | `10.0.21.0/24` | VPC-local traffic only |
| Database | `ap-southeast-1b` | `10.0.22.0/24` | VPC-local traffic only |

The public route table sends internet traffic through the Internet Gateway. The private application route table uses the NAT Gateway so EC2 instances can download updates without receiving public IP addresses.

#### 2. Security Layer

Security groups enforce traffic flow between the tiers:

- The ALB accepts public HTTP traffic on port `80`.
- Application instances accept HTTP traffic only from the ALB security group.
- The database accepts MySQL traffic on port `3306` only from the application security group.

```hcl
# Application tier: allow HTTP from the ALB only
ingress {
  from_port       = 80
  to_port         = 80
  protocol        = "tcp"
  security_groups = [aws_security_group.alb.id]
}

# Database tier: allow MySQL from the application tier only
ingress {
  from_port       = 3306
  to_port         = 3306
  protocol        = "tcp"
  security_groups = [aws_security_group.app.id]
}
```

#### 3. Presentation Tier

An internet-facing Application Load Balancer spans both public subnets. Its listener forwards HTTP requests to the application target group and uses health checks to route traffic only to healthy instances.

```hcl
resource "aws_lb" "external" {
  name               = "three-tier-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = [aws_subnet.public_1.id, aws_subnet.public_2.id]
}
```

#### 4. Application Tier

The application runs on Ubuntu 24.04 LTS EC2 instances in private subnets. A launch template installs Apache, while an Auto Scaling group maintains two instances and can scale up to four.

```hcl
resource "aws_autoscaling_group" "app" {
  name                = "three-tier-asg"
  vpc_zone_identifier = [aws_subnet.private_app_1.id, aws_subnet.private_app_2.id]
  target_group_arns   = [aws_lb_target_group.app.arn]

  desired_capacity = 2
  min_size         = 2
  max_size         = 4

  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }
}
```

#### 5. Data Tier

Amazon RDS for MySQL runs in the private database subnets. Its security group prevents direct public access and permits database connections only from the application tier.

```hcl
resource "aws_db_instance" "mysql" {
  allocated_storage      = 20
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"
  db_name                = "applicationdb"
  db_subnet_group_name   = aws_db_subnet_group.db.name
  vpc_security_group_ids = [aws_security_group.db.id]
  skip_final_snapshot    = true
  multi_az               = false
}
```

### providers.tf

The provider configuration sets the minimum Terraform version, pins the AWS provider to a compatible release, and deploys resources to the Singapore Region.

```hcl
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.58.0"
    }
  }
}

provider "aws" {
  region = "ap-southeast-1"
}
```

## Traffic Flow

```text
Internet
   |
   v
Application Load Balancer (public subnets)
   |
   v
EC2 Auto Scaling Group (private application subnets)
   |
   v
Amazon RDS for MySQL (private database subnets)
```

## Deploy the Infrastructure

1. Initialize the working directory:

   ```bash
   terraform init
   ```

2. Format and validate the configuration:

   ```bash
   terraform fmt -check
   terraform validate
   ```

3. Review the execution plan:

   ```bash
   terraform plan
   ```

4. Create the AWS resources:

   ```bash
   terraform apply
   ```

5. Enter `yes` when Terraform asks for confirmation. After deployment, open the Application Load Balancer DNS name shown in the AWS console to access the sample web page.

## Clean Up

Destroy the infrastructure when it is no longer needed to avoid ongoing AWS charges:

```bash
terraform destroy
```

Review the destruction plan, then enter `yes` to confirm.

## Production Considerations

This repository is a demonstration environment. Before using it for production workloads:

- Move the database credentials out of `main.tf` and store them in AWS Secrets Manager or provide them through sensitive Terraform variables.
- Enable HTTPS on the ALB with an ACM certificate and redirect HTTP traffic to HTTPS.
- Enable Multi-AZ deployment, backups, encryption, and deletion protection for RDS.
- Deploy one NAT Gateway per Availability Zone if application-tier network fault tolerance is required.
- Use a least-privilege IAM policy instead of granting `AdministratorAccess`.
- Store Terraform state remotely with encryption and state locking for team environments.
