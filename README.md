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

### main.tf
```
# VPC
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "Three-Tier-VPC"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "Three-Tier-NAT"
  }
}


```