# Three Tier Web Application Architecture Using Terraform

This project delivers an automated, highly available, and secure three-tier web application architecture on AWS using Terraform to ensure consistent, repeatable, and scalable infrastructure deployments. The architecture isolates workloads into specialized logical layers across multiple Availability Zones (AZs) to achieve maximum fault tolerance and minimize the blast radius of potential security incidents.

![alt text](three-tier-web-app-architecture.webp)

## Create the IAM User
1. Log in to the **AWS Management Console** as an administrator.
2. Go to IAM (Identify and Access Management) and select IAM Users.
3. Click Create User
4. Enter a name: e.g.: <mark>solution-architect</mark> and click next
    - Leave the checkbox for "Provide user access to the AWS Management Console" unchecked since Terraform only requires programmatic CLI access
5. On the Set permissions page, select **Attach policies directly**.
6. In the Permissions policies search box, search for and check **AdministratorAccess** (or your custom restricted infrastructure policy).
7. Click **Next** at the bottom of the page.