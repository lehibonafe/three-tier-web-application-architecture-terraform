# Three Tier Web Application Architecture Using Terraform

This project delivers an automated, highly available, and secure three-tier web application architecture on AWS using Terraform to ensure consistent, repeatable, and scalable infrastructure deployments. The architecture isolates workloads into specialized logical layers across multiple Availability Zones (AZs) to achieve maximum fault tolerance and minimize the blast radius of potential security incidents.

![alt text](three-tier-web-app-architecture.webp)

## Create the IAM User
1. Log in to the **AWS Management Console** as an administrator.
2. Go to **IAM** (Identify and Access Management) and select **IAM Users**.
3. Click **Create User**
4. Enter a name: e.g.: `solution-architect` and click **Next**
    - Leave the checkbox for "Provide user access to the AWS Management Console" unchecked since Terraform only requires programmatic CLI access
5. On the **Set permissions** page, select **Attach policies directly**.
6. Search for and check **AdministratorAccess**.
7. Click **Next** at the bottom of the page.

## Generate Access Keys
1. Click your new created user `solution-architect`
2. Select the **Security credentials** tab.
3. Scroll down **Create access key**.
4. Select **Command Line Interface (CLI)**.
5. check the confirmation box indicating you understand the recommendations, and click **Next**.
6. Add a description tag, such as `Terraform Deployment Key`, and click **Create access key**
7. Click **Download .csv file** to save these keys to your local machine.
