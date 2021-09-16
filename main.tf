# Lets set up or cloud provider with Terraform


provider "aws" {
  region = "eu-west-1"
}


# Lets start with Launching an EC2 instance using the app AMI

resource "aws_instance" "app_instance" {
 ami = "ami-00cce017f5ffc9635"
 instance_type = "t2.micro"
 associate_public_ip_address = true
 tags = {
   Name = "sre_zeeshan_terraform_app" 
 }

}

# ami id ` `
# `sre_key.pem` file
# AWS keys setup is already done
# public ip
# type of the instance `t2micro`
