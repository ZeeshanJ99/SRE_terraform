# Terraform Orchestration

------------------------------------

## What is terraform
Terraform (made by hashicorp) is a service Orchestration tool. This is the automated configuration, management, and coordination of computer systems, applications, and services. Orchestration helps IT to more easily manage complex tasks and workflows. IT teams must manage many servers and applications, but doing so manually isn’t a scalable strategy. 

![image](https://user-images.githubusercontent.com/88186084/133647175-bb2ea567-2952-4454-a8de-6a5c299d6b41.png)


-----------------------------------------------------------
## Securing AWS keys for terraform

- Search `env` after pressing the windows key
- Select `edit the system environment variables`
- In the `advanced` header select `environment variables`

- Under User variables select `new`
- Create the name `AWS_ACCESS_KEY_ID` and paste in your AWS access key as the `value`
- Create another name as `AWS_SECRET_ACCESS_KEY` and paste in your AWS secret key as the `value`

**Never share these keys with anyone**

--------------------------------------------------------

## Setting up Terraform

- create env var to secure AWS keys
- Restart the terminal
- Create a file called `main.tf`
- add the code to initialise terraform with provider AWS on the `main.tf` file

        provider "aws" {
            region = "eu-west-1"
        }

- Lets run this code with `terraform init`

---------------------------------------------------------------------

### Creating resources on AWS
- Lets start with Launching an EC2 instance using the app AMI
- ami id
- `sre_key.pem` file
- AWS keys setup is already done
- public ip
- type of the instance `t2micro`

This will also take place in the `main.tf` file underneath the code for intialising:


        # Lets start with Launching an EC2 instance using the app AMI

        resource "aws_instance" "app_instance" {
        ami = "ami-00cce017f5ffc9635"
        instance_type = "t2.micro"
        associate_public_ip_address = true
        tags = {
        Name = "sre_zeeshan_terraform_app"
        }

        }

---------------------------------------------

## Main commands for terraform:
- Initialise terraform - `terraform init`
- Check any syntax errors `terraform plan`
- Apply your changes - `terraform apply`
- Destroy - `terraform destroy`


        init          Prepare your working directory for other commands
        validate      Check whether the configuration is valid
        plan          Show changes required by the current configuration
        apply         Create or update infrastructure
        destroy       Destroy previously-created infrastructure

        All other commands:
        console       Try Terraform expressions at an interactive command prompt
        fmt           Reformat your configuration in the standard style
        force-unlock  Release a stuck lock on the current workspace
        get           Install or upgrade remote Terraform modules
        graph         Generate a Graphviz graph of the steps in an operation
        import        Associate existing infrastructure with a Terraform resource
        login         Obtain and save credentials for a remote host
        logout        Remove locally-stored credentials for a remote host
        output        Show output values from your root module
        providers     Show the providers required for this configuration
        refresh       Update the state to match remote systems
        show          Show the current state or a saved plan
        state         Advanced state management
        taint         Mark a resource instance as not fully functional
        test          Experimental support for module integration testing
        untaint       Remove the 'tainted' state from a resource instance
        version       Show the current Terraform version
        workspace     Workspace management

---------------------------------------------------------------------------------

# Main.tf code which will launch app and db instances

![image](https://user-images.githubusercontent.com/88186084/133792446-c532c53c-564f-4275-82dd-3f288fcb2123.png)

----------------------------------------------------------------
        
## Lets set up or cloud provider with Terraform

        provider "aws" {
        region = "eu-west-1"
        }

----------------------------------------

## VPC

        resource "aws_vpc" "sre_zeeshan_vpc_tf" {
        cidr_block       = "10.109.0.0/16"
        instance_tenancy = "default"

        tags = {
        Name = "sre_zeeshan_vpc_tf"
        }
                }

--------------------------------------------------

## Subnet - App

        resource "aws_subnet" "sre_zeeshan_app_subnet" {
                vpc_id = var.vpc_id
                cidr_block = "10.109.9.0/24"
                map_public_ip_on_launch = "true"  # Makes this a public subnet
                availability_zone = "eu-west-1a"

                tags = {
                        Name = "sre_zeeshan_tf_app"
                }
        }
        
 -------------------------------------------------
 
 ## Subnet - db
 
    resource "aws_subnet" "sre_zeeshan_db_subnet" {
            vpc_id = var.vpc_id
            cidr_block = "10.109.10.0/24"
            map_public_ip_on_launch = "true"  # Makes this a public subnet
            availability_zone = "eu-west-1a"

            tags = {
                    Name = "sre_zeeshan_tf_db"
            }
     }


--------------------------------------------------------------------------

## Security groups and rules - app

        resource "aws_security_group" "sre_zeeshan_app_sg_terraform"  {
        name = "sre_zeeshan_app_sg_terraform"
        description = "sre_zeeshan_app_sg_terraform"
        vpc_id = var.vpc_id # attaching the SG with your own VPC

-------------------------------

### Inbound rules - app

        ingress {
        from_port       = "80"
        to_port         = "80"
        protocol        = "tcp"
        cidr_blocks     = ["0.0.0.0/0"]
        }

------------------------------------

#### SSH access - app

        ingress {
                from_port       = "22"
                to_port         = "22"
                protocol        = "tcp"
                cidr_blocks     = ["0.0.0.0/0"]
                }

-----------------------------------------------

#### Allow port 3000 - app

        ingress {
                from_port       = "3000"
                to_port         = "3000"
                protocol        = "tcp"
                cidr_blocks     = ["0.0.0.0/0"]
        }

--------------------------------------------------------

### Outbound rules - app

    egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1" # allow all
    cidr_blocks     = ["0.0.0.0/0"]
        }

        tags = {
        Name = "sre_zeeshan_app_sg_terraform"
        }
                }

------------------------------------------------------

## Security groups and rules - db

        resource "aws_security_group" "sre_zeeshan_db_sg_terraform"  {
         name = "sre_zeeshan_db_sg_terraform"
         description = "sre_zeeshan_db_sg_terraform"
         vpc_id = var.vpc_id # attaching the SG with your own VPC

----------------------------------------------------------

### Inbound rules - db

    ingress {
      from_port       = "27017"
      to_port         = "27017"
      protocol        = "tcp"
      cidr_blocks     = ["0.0.0.0/0"]
    }

-------------------------------------

#### SSH access - db

    ingress {
      from_port       = "22"
      to_port         = "22"
      protocol        = "tcp"
      cidr_blocks     = ["0.0.0.0/0"]
    }
  
----------------------------------------  

### Outbound rules - db

      egress {
      from_port       = 0
      to_port         = 0
      protocol        = "-1" # allow all
      cidr_blocks     = ["0.0.0.0/0"]
    }

    tags = {
      Name = "sre_zeeshan_db_sg_terraform"
    }
     }

------------------------------------------------------------------

## Internet Gateway

        resource "aws_internet_gateway" "sre_zeeshan_terraform_ig" {
        vpc_id = var.vpc_id

        tags = {
        Name = "sre_zeeshan_terraform_ig"
        }
        }

-------------------------------------------

## Route table

        resource "aws_route" "sre_zeeshan_route_ig_connection" {
        route_table_id = var.route_table_id
        destination_cidr_block = "0.0.0.0/0"
        gateway_id = var.internet_gateway_id
        }

-----------------------------------------------

## Launching an app EC2 instance

        resource "aws_instance" "app_instance" {
        ami = var.app-ami-id
        subnet_id = var.aws_subnet
        vpc_security_group_ids = [var.sg_id]
        instance_type = "t2.micro"
        associate_public_ip_address = true
        tags = {
        Name = "sre_zeeshan_terraform_app"
        }

        key_name = var.sre_key_name

        connection {
                type = "ssh"
                user = "ubuntu"
                private_key = var.aws_key_path
                host = "${self.associate_public_ip_address}"
        }

        # provisioner "remote-exec"{
        # inline = [
        #       "cd app/app",
        #        "pm2 start app.js"
        #]
        #}

        }

Provisioner is commented out as it does not work at the moment.

----------------------------------------------------------

## Launching a db instance

    resource "aws_instance" "db_instance" {
     ami = var.db_ami_id
     subnet_id = var.db_subnet
     vpc_security_group_ids = [var.db_sg]
     instance_type = "t2.micro"
     associate_public_ip_address = true
     tags = {
       Name = "sre_zeeshan_terraform_db"
      }

     key_name = var.sre_key_name

    connection {
                    type = "ssh"
                    user = "ubuntu"
                    private_key = var.aws_key_path
                    host = "${self.associate_public_ip_address}"
            }
    }


----------------------------------------------------------------------------

## Variable.tf
The variable.tf file is where you can add your variables in so that they are not visible on the main.tf. This should be added to `.gitignore` as to keep the contents safe. They are referenced with a `var.name` within the code above. This is done with a wide variety of variables you will use. These following variable examples have been added to the file and referenced in the code above:

- VPC
- Name
- App AMI
- DB AMI
- App Subnet
- DB Subnet
- Internet Gateway
- Route table
- Security Groups for app (sg_id)
- Security Groups for db (db_sg)


The way in which to set out all the variables within the variable.tf file is as follows:

        variable "vpc_id" {
        default = "your vpc-id here"
        }

