# Terraform Orchestration
## What is terraform
## Why use Terraform
#### Setting up Terraform
##### Securing AWS keys for terraform

- create env var to secure AWS keys
- Restart the terminal
- Create a file called main.tf
- add the code to initialise terraform with provider AWS on the `main.tf` file

        provider "aws" {
            region = "eu-west-1"
        }

- Lets run this code with `terraform init`

### Creating resources on AWS
- Lets start with Launching an EC2 instance using the app AMI
- ami id ` `
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


terraform init
terraform plan
terraform apply
terraform destroy




## Main commands for terraform:

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
