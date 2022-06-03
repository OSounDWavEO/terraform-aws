# README #

### Summary ###
This repository contains the AWS modules to provision the AWS basic resources for web hosting such as VPC, EC2, RDS, and application load balancer. 

### Version ###
1.13

### Setting up ###
1. Install Terrraform on your machine.
2. In each directory, create terraform.tfvars file. This file excluded from this repo by .gitignore.
3. Add content in terraform.tfvars. Mostly, it contains the name of key pair and other secrets.
4. Create AWS credentials file named credentials in {*your home*}/.aws with below content:

[default]

aws_access_key_id = {*your access key*}

aws_secret_access_key = {*your secret key*}

### Working with Terraform ###
1. run "terraform init" to download module
2. run "terraform plan" to see the changes
3. run "terraform apply" to apply new configurations
