# Terraform Orchestration

------------------------------------

# What is Terraform
Terraform is HashiCorp’s infrastructure as code tool. It lets you define resources and infrastructure in human-readable, declarative configuration files, and manages your infrastructure’s lifecycle. It allows for automated configuration, management, and coordination of computer systems, applications, and services. 
Using a service orchestration tool such as terraform helps to more easily manage complex tasks and workflows. IT teams must manage many servers and applications, but doing so manually isn’t a scalable strategy.


![image](https://user-images.githubusercontent.com/88186084/133931163-7ef55c76-0f36-4526-9c06-296b26fee6e0.png)

-------------------------------------------------------------------------------------------------

## Watch this video to find out more!

<p><a href="https://learn.hashicorp.com/tutorials/terraform/infrastructure-as-code?wvideo=mo76ckwvz4"><img src="https://embed-fastly.wistia.com/deliveries/41c56d0e44141eb3654ae77f4ca5fb41.jpg?image_play_button_size=2x&amp;image_crop_resized=960x540&amp;image_play_button=1&amp;image_play_button_color=1563ffe0" width="800" height="500" style="width: 400px; height: 225px;"></a></p><p><a href="https://learn.hashicorp.com/tutorials/terraform/infrastructure-as-code?wvideo=mo76ckwvz4">Introduction to Infrastructure as Code with Terraform </a></p>

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
- Initialise terraform in current directory - `terraform init`
- Check any syntax errors in `.tf` files -  `terraform plan`
- Applies changes to `.tf` and executes - `terraform apply`
- Destroys all infrastructure - `terraform destroy`

-------------------------------------------------------------

## Here are some more terraform commands that may be of use:

        
        validate      Check whether the configuration is valid
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

![image](https://user-images.githubusercontent.com/88186084/133931657-0376cc37-dbd9-4093-ab7d-93956f27b77f.png)

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
        
        
------------------------------------------------------------

# Load Balancing and Auto Scaling
![image](https://user-images.githubusercontent.com/88186084/133896522-55cf7dc4-9b13-480f-9db0-980d6cabd558.png)

-----------------------------------------------------

## Creating a launch configuration

    resource "aws_launch_configuration" "app_launch_configuration" {
        name = "sre_zeeshan_app_launch_configuration"
        image_id = var.app-ami-id
        instance_type = "t2.micro"
    }

------------------------------------------------------------

## Creating an application load balancer

    resource "aws_lb" "sre-zeeshan-tf-LB" {
        name = "sre-zeeshan-LB-tf"
        internal = false
        load_balancer_type = "application"
        subnets = [
            var.aws_subnet,
            var.db_subnet
        ]
        # security_groups =

        tags = {
            Name = "sre-zeeshan-tf-LB"
        }
    }

--------------------------------------------------

## Creating an instance target group

    resource "aws_lb_target_group" "sre-zeeshan-app-tf-TG" {
        name = "sre-zeeshan-app-tf-TG"
        port = 80
        protocol = "HTTP"
        vpc_id = var.vpc_id
        # target_type = instance (default)

        tags = {
            Name = "sre_zeeshan_tf_TG"
        }
        }


----------------------------------------

## Creating a listener

    resource "aws_lb_target_group_attachment" "sre-zeeshan-app-tf-TG" {
        target_group_arn = aws_lb_target_group.sre-zeeshan-app-tf-TG.arn
        target_id = aws_instance.app_instance.id
        port = 80
        }

    resource "aws_lb_listener" "sre_zeeshan_listener" {
        load_balancer_arn = aws_lb.sre-zeeshan-tf-LB.arn
        port = 80
        protocol = "HTTP"

    default_action {
        type = "forward"
        target_group_arn = aws_lb_target_group.sre-zeeshan-app-tf-TG.arn
    }
     }

---------------------------------------------------------------------

## Creating an Auto Scaling group (for launch configuration)

    resource "aws_autoscaling_group" "sre_zeeshan_tf_ASG" {
        name = "sre_zeeshan_tf_ASG"

        min_size = 1
        desired_capacity = 1
        max_size = 3

        vpc_zone_identifier = [
            var.aws_subnet,
            var.db_subnet
        ]

        launch_configuration = aws_launch_configuration.app_launch_configuration.name
    }

    resource "aws_autoscaling_policy" "app_ASG_policy" {
        name = "sre_zeeshan_app_ASG_policy"
        policy_type = "TargetTrackingScaling"
        estimated_instance_warmup = 100
        # Use "cooldown" or "estimated_instance_warmup"
        # Error: cooldown is only used by "SimpleScaling"
        autoscaling_group_name = aws_autoscaling_group.sre_zeeshan_tf_ASG.name

        target_tracking_configuration {
            predefined_metric_specification {
                predefined_metric_type = "ASGAverageCPUUtilization"
                # Need to make sure to use valid options here
            }
            target_value = 50.0
        }
    }
    
----------------------------------------------------

## Creating a scale down policy

    resource "aws_autoscaling_policy" "app_ASG_scaledown_averageNetworkIn_policy" {
        name = "sre_zeeshan_ASG_scale_down_averageNetworkIn_policy"
        # Scaledown averageNetworkIn policy
        scaling_adjustment = -1
        adjustment_type = "ChangeInCapacity"
        cooldown = 300
        autoscaling_group_name = aws_autoscaling_group.sre_zeeshan_tf_ASG.id
    }
    
-------------------------------------------------------------

## Creating an alarm on cloudwatch

    resource "aws_cloudwatch_metric_alarm" "scale_down_averageNetworkIn_alarm_metric" {
        alarm_name = "Scaledown averageNetworkIn alarm"
        comparison_operator = "LessThanThreshold"
        metric_name = "NetworkIn"
        statistic = "Average"
        threshold = "500000"
        period = "120"
        evaluation_periods = "2"
        namespace = "AWS/EC2"
        alarm_description = "Monitors ASG EC2 average network in (for scale down policy)"
        alarm_actions = [aws_autoscaling_policy.app_ASG_scaledown_averageNetworkIn_policy.arn]
    }

