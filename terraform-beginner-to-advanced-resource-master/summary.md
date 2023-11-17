Getting Started & Setting Up Labs : Choosing a right Infrastructure as Code tool
******************************************************************************** 
- Terraform
- CloudFormation
- Heat
- Ansible
- SaltStack
- Chef, Puppet and Others


Configuration Management vs Infrastructure Orchestration
--------------------------------------------------------
Ansible, Chef, Puppet are configuration management tools which means that they are primarily designed to install and
manage software on existing servers.

Terraform and Cloudformation are infrastructure orchestration tools which basically means they can provision the servers
and infrastructure by themselves.


Benefits of using Terraform:
---------------------------
. Support multiple platforms, has hundreds of providers.
. Simple configuration language and faster learning curve
. Easy integration with configuration management tools like Ansible
. Easily extensible with the  help of plugins
. Free


Installing Terraform - MacOS and Linux Users
--------------------------------------------
. Download the binary
. Move it under /usr/local/bin


Choosing Right IDE for Terraform IAC development
------------------------------------------------
. Download ATOM
. Install the package : language-terraform

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Deploying Infrastructure with Terraform
***************************************
When you want to launch a resource in AWS , thre are three points to consider.
1. How will you authenticate ti AWS
2. Which region the resource needs to be launched.
3. Which resource you want to launch.


Creating first EC2 instance with Terraform
------------------------------------------
Step 1. Create an user for terraform
. IAM --> Users --> Add User --> Username: terraform_user
                                 Access type : Programmatic Access
                                 Attach Existing Policy : Administrator Access
                                 
Step 2. Write the terraform script.
>>  vi first_ec2.tf
    # Configure the AWS Provider
    provider "aws" {
      region = "us-east-1"
      access_key = "PUT-YOUR-ACCESS-KEY-HERE"
      secret_key = "PUT-YOUR-ACCESS-KEY-HERE"
    }

    resource "aws_instance" "MyAutomatedEC2" {               # aws_instance Provides an EC2 instance resource.
      ami = "ami-0d5eff06f840b45e9"                          # This allows instances to be created, updated, 
      instance_type = "t2.micro"                             # and deleted. Instances also support provisioning.
    }
                                 
Step 3. Execute the script
>>  terraform init
>>  terraform plan
>>  terraform apply

Reference : https://github.com/zealvora/terraform-beginner-to-advanced-resource/blob/master/Section%201%20-%20Deploying%20Infrastructure%20with%20Terraform/first-ec2.md


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Understanding Resources & Providers - NEW
*****************************************
Providers 
---------
Whenever you add a provider, it is importaint to run terraform init which in-turn will download plugins associated with the 
provider.

Note : Whenever you add a provider to your terraform script, you should do terraform init to download the necessary plugin
associated with that provider.

Resource
--------
Resources are the reference to the individual services which the provider has to offer.
Eg. resource aws_instance
    resource aws_alb
    resource iam_user

Also from terraform 0.13+, you need to use the followong syntax if you are using a provider which is not hashicorp maintained,

      terraform {
        required_providers {
          digitalocean = {
            source = "digitalocean/digitalocean"
            version = "2.9.0"
          }
        }
      }

      provider "digitalocean" {
        # Configuration options
      }


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Understanding Resource & Providers - Part 2 NEW
***********************************************
Demo : Create a Github repository using terraform. So our provider is github.
----------------------------------------------------------------------------
>>  Search terraformm github provider to findout the terraform github provider details.

>>  vi github_repo.tf
    terraform {
      required_providers {
        github = {
          source = "integrations/github"
          version = "4.10.1"
        }
      }
    }

    provider "github" {
      # Configuration options
      token = "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"
    }

    resource "github_repository" "MyTerraformRepo" {
      name = "MyTerraformRepo"

      visibility = "private"
    }

>>  terrafrom init
>>  terraform plan
>>  terraform apply       ==>   Creates a private git repo named 'MyTerraformRepo'


So when you have multiple .tf file exist and you wanted to apply only on one
>>  terraform init
>>  terraform plan
>>  terrafrom apply -target resource_type.resource_name
Eg. terrafrom apply -target github_repository.MyTerraformRepo

Running a specific terraform file when multiple .tf file exist
--------------------------------------------------------------
>>  terraform plan -target resource_type.resource_name
>>  terrafrom apply -target resource_type.resource_name


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Destroying Infrastructure with Terraform (NEW)
***********************************************
Terrafrom destroy : Delete all resources
----------------------------------------
>>  terraform destroy

Terrafrom destroy : Delete only specific resources (use target option)
----------------------------------------------------------------------
>>  terraform destroy -target resource_type.resource_name
Eg. terrafrom destroy -target github_repository.MyTerraformRepo


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Understanding Terraform State files (NEW)
*****************************************
. Terraform stores the state of the infrastructure that is being created from the TF files.
. And this state allows terraform to map real world resource to your existing configuration.
. Also when you destroy a resource / all resources, then corresponding informing will be removed from terrafrom state files.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Understanding Desired & Current States (NEW)
********************************************
. Terraform's primary function is to create, modify and destroy infrastructure resources to match the desired state described 
  in a Terraform configuration.

. Current state represents the actual state of a resource that is currently deployed.

. Terraform tries to ensure that the deployed infrastructure is based on the desired state.

. If there is a difference between the two, then executing the >>  terraform plan presents a description of the changes 
  necessary to achieve the desired state.
  
Eg. Currently I have an EC2 instance running with instance type = t2.micro (both desired state and current state is same)
    And when you do the folowing
>>  terraform plan  ===> no changes since both desired and current state are the same.

Now stop the EC2 instance and change it to t2.nano (Stop instance and use actions --> instance setting to set t2.nano)

Now when you do the following
>>  terraform refresh --> update the state file with instance type to t2.nano
>>  terraform plan    --> shows that we need to update from t2.nano to t2.micro ie from current state to desired state


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Challenges with the current state on computed values (NEW)
**********************************************************
So when you use a terraform script to create an ec2 instance with minimal required info, lets take the one below 

  resource "aws_instance" "MyAutomatedEC2" {              
    ami = "ami-0d5eff06f840b45e9"                          
    instance_type = "t2.micro"                            
  }

Once the EC2 instance is created and if you update the default SG with custom security group and use that with your EC2 
instance instead of the default one, then when you do terraform plan command, terraform wont notify about the change since 
security group configuration was not added in your terraform script(desired state).

So to avoid this, whenever you create a resource, donot just specify minimal things. Specify all the important things that 
are necessary including the iam role, security group etc as part of terraform configuration. So it always matches the desired
state when you run the command terraform plan


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Terraform Provider Versioning
*****************************
When you do terraform init and if you haven't provided the version in your script, then terraform will pull the latest version
of resource plugin. Thats why you should provide version number in your script.

terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "3.44.0"             < - - - - - - -  VERSION
    }
  }
}

provider "aws" {
  # Configuration options
}

There are multiple ways for specifying the version of a provider.

------------------------------------------------------------------------------------
|  Version Number Arguments        |             Description                       |
------------------------------------------------------------------------------------
|        >=1.0                     |             Greater than equal to the version |
|        <=1.0                     |             Less than equal to the version    |
|        ~>2.0                     |             Any version in the 2.X range      |
|        >=2.10, <=2.30            |             Any version between 2.10 and 2.30 |
------------------------------------------------------------------------------------

So if you are using version 2.0 in your provider and when you do terraform init a lock file is created. And now if you try
to change the version 3.0 and do terraform init, it will throw an error. 

To avoid this, do the following
>>  terraform init -upgrade

NOTE : Terraform dependency lockfile allow us to lock to a specific version of the provider.

If a particular provider already has a selection recorded in the lock file, Terraform will always reselect that version for
installation, even if a newer version has become available.

You can override that behaviour by adding -upgrade option when you run terraform init.
>>  terraform init -upgrade


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Read, Generate, Modify Configurations
*************************************
Understanding Attributes and Output Values in Terraform
--------------------------------------------------------
Terraform has capability to output the attribute of a resource with the output values. Means let say you launched an ec2
instance via terraform. Then if you need to know some info regarding the ec2 instance say ip address of that instance.
Normally people go and look at it in the aws ui. But you can actually tell terraform to output those required values once 
the terraform apply command is executed.

Also note that an outputed attributes can not only be used for the user reference but it can also act as a input to other
resources being created via terraform.

Eg 1. Printing attribute value as output
----------------------------------------
provider "aws" {
  region     = "us-west-2"
  access_key = "PUT-YOUR-ACCESS-KEY-HERE"
  secret_key = "PUT-YOUR-SECRET-KEY-HERE"
}

resource "aws_eip" "lb" {                          <--- resource creating an elastic ip
  vpc      = true
}

output "eip" {                                     <---- returning the elastic ip address
  value = aws_eip.lb.public_ip                           resource.resource_name.attribute_name
}                       |
                        |------------------------------> Look at the Attributes Reference section 
                                                         of the resource in TF registry page

>>  terraform init
>>  terraform plan
>>  terraform aapply

Outputs:
--------
>>  elastic_ip_info = "50.16.193.201"


Eg 2. Printing whole attribute values
-------------------------------------
provider "aws" {
  region     = "us-west-2"
  access_key = "PUT-YOUR-ACCESS-KEY-HERE"
  secret_key = "PUT-YOUR-SECRET-KEY-HERE"
}

resource "aws_eip" "lb" {                          <--- resource creating an elastic ip
  vpc      = true
}

output "eip" {                                     <---- returning the elastic ip address
  value = aws_eip.lb                                     resource.resource_name
}

>>  terraform init
>>  terraform plan
>>  terraform aapply

Outputs:
--------
Outputs:

>>  elastic_ip_info = {
      "address" = tostring(null)
      "allocation_id" = tostring(null)
      "associate_with_private_ip" = tostring(null)
      "association_id" = ""
      "carrier_ip" = ""
      "customer_owned_ip" = ""
      "customer_owned_ipv4_pool" = ""
      "domain" = "vpc"
      "id" = "eipalloc-08146ca73072fb52c"
      "instance" = ""
      "network_border_group" = "us-east-1"
      "network_interface" = ""
      "private_dns" = tostring(null)
      "private_ip" = ""
      "public_dns" = "ec2-3-95-84-242.compute-1.amazonaws.com"
      "public_ip" = "3.95.84.242"
      "public_ipv4_pool" = "amazon"
      "tags" = tomap(null) /* of string */
      "tags_all" = tomap({})
      "timeouts" = null /* object */
      "vpc" = true
    }


For any resource, what all values you can output is mentioned under the title "Attributes Reference" in terraform registry
page.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Referencing Cross-Account Resource Attributes
*********************************************
An outputted attribute can not only used for the user reference but it can also act as a input to other resources being
created via terraform.

Eg 1. Create an elastic IP  --> Create an EC2 instance --> Allocate the elastic IP to the EC2 instance
------------------------------------------------------------------------------------------------------
provider "aws" {
  region = "us-east-1"
  access_key = "AKIA6MTOAS67E44UU65R"
  secret_key = "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"
}

# Creating EC2 Instance.
resource "aws_instance" "my_ec2" {                                          
  ami = "ami-0d5eff06f840b45e9"
  availability_zone = "us-east-1a"
  instance_type = "t2.micro"
  tags = {
    Name = "MyEC2Instance"
  }
}

# Creating Elastic IP Resource.
resource "aws_eip" "my_eip" {                                               
    vpc      = true
}

# Attaching Elastic IP to EC2 Instance.
resource "aws_eip_association" "eip_assoc" {                                
  instance_id   = aws_instance.my_ec2.id
  allocation_id = aws_eip.my_eip.id
}


Eg 2. Create an elastic IP  --> Create a security group & make sure the elastic ip attribute is added in the security group
---------------------------------------------------------------------------------------------------------------------------
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "3.44.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
  access_key = "AKIA6MTOAS67E44UU65R"
  secret_key = "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"
}

# Creating EC2 Instance.
resource "aws_instance" "my_ec2" {                                          
  ami = "ami-0d5eff06f840b45e9"
  availability_zone = "us-east-1a"
  instance_type = "t2.micro"
  tags = {
    Name = "MyEC2Instance"
  }
}

# Creating Elastic IP Resource.
resource "aws_eip" "my_eip" {                                               
    vpc      = true
}

# Attaching Elastic IP to EC2 Instance.
resource "aws_eip_association" "eip_assoc" {                                
  instance_id   = aws_instance.my_ec2.id
  allocation_id = aws_eip.my_eip.id
}

# Creating a security group and defining elastic ip over there. Not attached to EC2 instance.
resource "aws_security_group" "allow_tls" {
    name        = "allow_tls"
    
    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["${aws_eip.my_eip.public_ip}/32"]
        # cidr_blocks = [aws_eip.my_eip.public_ip/32]  # If this doesn't work, use the above approach.
    }

    tags = {
        Name = "allow_tls"
    }
}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Terraform Variables
*******************
Instead of hardcoding the value every where, we can store the value in a central source and then access the variable from 
the source.

>>  vi variables.tf

    variable "vpn_ip" {
        default = "116.50.30.50/32"
    }    


>>  vi variable_demo.tf

    terraform {..}

    provider "aws" {..}

    resource "aws_security_group" "allow_tls" {
        name        = "vsk_security_group"
        description = "Allow TLS inbound traffic"

        ingress {
            from_port        = 443
            to_port          = 443
            protocol         = "tcp"
            cidr_blocks      = [var.vpn_ip]      # Using the IP defined in the variable file.
        }

        ingress {
            from_port        = 80
            to_port          = 80
            protocol         = "tcp"
            cidr_blocks      = [var.vpn_ip]      # Using the IP defined in the variable file.
        }

        ingress {
            from_port        = 53
            to_port          = 53
            protocol         = "tcp"
            cidr_blocks      = [var.vpn_ip]       # Using the IP defined in the variable file.
        }

        tags = {
            Name = "vsk_security_group"
        }
    }

>>  terafotm init 
>>  terafotm plan 
>>  terafotm apply      --> this will create security group with the ip range  


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Approaches for Variable Assignment
**********************************
Variables in terraform can be assigned valuesi n multiple ways. Some of these include
. Environment Variables
. Command Line Flags
. From a file
. Variable Defaults


Using Variable Defaults
------------------------
>>  vi my_first_ec2.tf

    provider "aws" {
        region     = "us-west-2"
        access_key = "PUT-YOUR-ACCESS-KEY-HERE"
        secret_key = "PUT-YOUR-SECRET-KEY-HERE"
    }

    resource "aws_instance" "MyAutomatedEC2" {
        ami = "ami-0d5eff06f840b45e9"           
        instance_type = var.instancetype              
    }


>>  vi variables.tf

    variable "instancetype" {
        default = "t2.micro"
    }


>>  terraform init
>>  terraform plan  --> you will see the instance type is t2.micro


Using Command Line Flags : Assigning a value explicitly
-------------------------------------------------------
>>  terraform plan -var="instancetype=t2.small"


Using Command Line Flage : Setting no default values in the variables.tf
------------------------------------------------------------------------
>>  vi variables.tf

    variable "instancetype" {}            ==> No default value is defined here.


>>  terraform plan
    var.instancetype
      Enter a value: t2.medium            ==> So it ask for user input


Using from a file option
------------------------
>>  vi variables.tf
    variable "instancetype" {
        default = "t2.micro"              ==> Variable defined with default value here.
    }    
    
>>  vi terraform.tfvars
    instancetype=t2.large                 ==> Actual value defined here
    
>>  terraform plan                        ==> you will see the instance type as t2.large

In a production environment, this is considered as the best approach where we have a variables.tf file containing the 
variable name and terraform.tfvars file where the value for that variable is defined.

Note : naming of the file is very important. You should name the variable value file as terraform.tfvars


Lets say if you used the name custom.tfvars for the file containing values of the variables defined in the variables.tf
>>  terraform plan -var-file="custom.tfvars"


Using Environment variable
--------------------------
Windows
-------
>>  setx TF_VAR_instancetype m5.large    (NOTE : TF_VAR_variablename is the syntax)

>>  open a new window

>>  echo %TF_VAR_instancetype%            (If you try in same command prompt, it wont work)
    m5.large
    
>>  terrafrom plan    


Linux
----
>>  export TF_VAR_instancetype="m5.large"

>>  echo TF_VAR_instancetype

>>  m5.large

>>  terraform plan

NOTE : In production, best approach is creating variables.tf with default value & terraform.tfvars with actual value for the 
       variable defined in the variables.tf file.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Data Types for Variables
************************
In your variable.tf file where you define the default value, you can define the type of the variable as well so that if we
use a vaue of different type in terraform.tfvars, then it will throw an error.

Note : if no type is set, then values of any type is accepted.

Syntax : 
--------
>>  variable "variable_name" {
      type = string
    }
    
Available Data types in Terraform
---------------------------------
. string  : Eg. "hello"
. list    : Eg. ["mumbai", "singapore", "usa"]
. map     : Eg. {name = "Mabel", age = 52}
. number  : Eg. 200
. bool    : Eg. true / false
. null    : Eg. null


Lets look an example of Create a new load balancer
>>  vi elastic_load_balance.tf
>>  terraform {..}

    provider "aws" {..}

    # Create a new load balancer
    resource "aws_elb" "bar" {
        name               = var.elb_name                                #  variable name of type string
        availability_zones = var.az                                      #  variable name of type list

        listener {..}

        health_check {..}

        cross_zone_load_balancing   = var.cross_zone_load_balancing     #  variable name of type boolean
        idle_timeout                = var.timeout                       #  variable name of type number
        connection_draining         = true
        connection_draining_timeout = var.timeout                       #  variable name of type number

        tags = {
            Name = "foobar-terraform-elb"
        }
    }


>>  vi variables.tf
    variable "elb_name" {
        description = "Name of the ELB"
        type = string
        default = "vysakh-elb"          # default valut will be picked up only if no values passed on terraform.tfvars file.
    }

    variable "az" {
        description = "A list representing the availability zones"
        type = list
        default = null
    }

    variable "timeout" {
        description = "A number representing the timeout value"
        type = number
        default = 200
    }

    variable "cross_zone_load_balancing" {
        description = "Enable ccross-zone load balancing"
        type = bool
        default = false
    }


>>  vi terraform.tfvars

    elb_name = "my-first-elb"
    timeout = "400"
    az = ["us-east-1a","us-east-1b"]
    cross_zone_load_balancing = true


>>  terraform init
    terraform plan
    
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Fetching Data from Maps and List in Variable
********************************************
>>  vi map_or_list.tf

    provider "aws" {..}

    resource "aws_instance" "myec2" {
       ami = "ami-082b5a644766e0e6f"
       instance_type = var.list[1]                    ==> Pulling the value from the list.
                  OR
       instance_type = var.types[ap-south-1]          ==> Pulling the value from the map.                  
    }

    variable "list" {
      type = list
      default = ["m5.large","m5.xlarge","t2.medium"]
    }

    variable "types" {
      type = map
      default = {
        us-east-1 = "t2.micro"
        us-west-2 = "t2.nano"
        ap-south-1 = "t2.small"
      }
    }


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Count and Count Index
*********************
So when you want to create more than one instance of any resource, one option is to use the resource code snippet as many 
times as needed.  And this is not the recommended approach.

Here we use count parameter and count index to tackle the above approach.

Using Count
-----------
provider "aws" {..}


resource "aws_instance" "instance-1" {
   ami = "ami-082b5a644766e0e6f"
   instance_type = "t2.micro"
   count = 3
}

Using Count, Count Index and Naming different for each instance
---------------------------------------------------------------
Code to create iam users
------------------------
provider "aws" {..}

variable "elb_names" {
  type = list
  default = ["dev-loadbalancer", "stage-loadbalanacer","prod-loadbalancer"]
}

resource "aws_iam_user" "lb" {
  name = var.elb_names[count.index]
  count = 3
  path = "/system/"
}

So here the resource are creating and uses different names for each resource.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Conditional Expressions
***********************
Syntax : condition ? true_val : false_val

So conditional expression is used in a scenario where there are two resource blocks as part of terraform configuration.

Depending on the variable value, one of the resource blocks will run.

Let say we have a variable 'is-test'. If its value is true, then run the "dev" related ec2 configuration get executed else
execute the "prod" related configuration.

>>  vi conditional.tf

    provider "aws" {...}

    variable "istest" {}                   

    resource "aws_instance" "dev" {
       ami = "ami-082b5a644766e0e6f"           ===> this section get executed if the value of istest variable is true
       instance_type = "t2.micro"                   which leads to the creation of ec2 instance with dev configuration
       count = var.istest == true ? 1 : 0
    }

    resource "aws_instance" "prod" {
       ami = "ami-082b5a644766e0e6f"          ===> this section get executed if the value of istest variable is false
       instance_type = "t2.large"                  which leads to the creation of ec2 instance with dev configuration
       count = var.istest == false ? 1 : 0
    }

>>  vi terraform.tfvars
    
    istest = false
    

>>  terrafrom init
>>  terraform plan
>>  terraform apply


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Local Values (Refer : https://learn.hashicorp.com/tutorials/terraform/locals)
************ (Refer : https://learn.hashicorp.com/tutorials/terraform/locals?in=terraform/configuration-language)
. Terraform locals are named values that you can refer to in your configuration. 

. You can use local values to simplify your Terraform configuration and avoid repetition. 

. local values can also help you write more readable configuration by using meaningful names rather than hard-coding values

. A local value assigns a name to an expression, allowing it to be used multiple times within a module without repeating it.

. Local values can be helpful to avoid repeating the same value or expression multiple times in a configuration.

. If overused, they can also make a configuration hard to read by future maintainers by hiding the actual values used.

. Use local values only in moderation, in situations where a single value or result is used in many places & that value is 
  likely to be changed in future.

>>  vi terraform.tf

    provider "aws" {...}

    locals {                                  <=== Defining local value.
      common_tags = {
        Owner = "DevOps Team"
        service = "backend"
      }
    }
    resource "aws_instance" "app-dev" {
       ami = "ami-082b5a644766e0e6f"
       instance_type = "t2.micro"
       tags = local.common_tags               ===> These resource will inherit the common_tags.
    }

    resource "aws_instance" "db-dev" {
       ami = "ami-082b5a644766e0e6f"
       instance_type = "t2.small"
       tags = local.common_tags               ===> These resource will inherit the common_tags.
    }

    resource "aws_ebs_volume" "db_ebs" {
      availability_zone = "us-west-2a"
      size              = 8
      tags = local.common_tags                ===> These resource will inherit the common_tags.
    }

Here the tags are creeated only once and used multiple times.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Terraform Functions (Refer : https://www.terraform.io/docs/language/functions/index.html)
*******************
Terraform doesnot support user defined functions and so only the functions built into the language are available to use.
. Numeric
. String
. Collection
. Encoding
. Filesystem
. Date and Time
. Hash and Crypto
. IP Network
. Type Conversion

>>  terraform console     (if you wanted to try terraform builtin functions in terminal, first execute terraform console cmd)
>>  max(10, 20, 30)
    30


>>  vi functions.tf

    provider "aws" {..}

    locals {
      time = formatdate("DD MMM YYYY hh:mm ZZZ", timestamp())        ===> Defining locals and using function formatdate
    }                                                                     and timestamp

    variable "region" {                                              ===> Defining variable 'region'
      default = "ap-south-1"
    }

    variable "tags" {                                                ===> Defining variable 'tags'
      type = list
      default = ["firstec2","secondec2"]
    }

    variable "ami" {                                                 ===> Defining variable ami
      type = map
      default = {
        "us-east-1" = "ami-0323c3dd2da7fb37d"
        "us-west-2" = "ami-0d6621c01e8c2de2c"
        "ap-south-1" = "ami-0470e33cd681b2476"
      }
    }

    resource "aws_key_pair" "loginkey" {                  ===> Using file function reads the contents of a file at given
      key_name   = "login-key"                                 path and returns them as a string. Here return the content of 
      public_key = file("${path.module}/id_rsa.pub")           id_rsa.pub which resides in same location of this tf script
    }                                                             

    resource "aws_instance" "app-dev" {
       ami = lookup(var.ami,var.region)                     ===> Using lookup function, it checks the value 
       instance_type = "t2.micro"                                var.region in var.ami and use that matching value
       key_name = aws_key_pair.loginkey.key_name                 Here its ami['ap-south-1] -> ami-0470e33cd681b2476
       count = 2

       tags = {
         Name = element(var.tags,count.index)               ===> Using element function retrieves a single element 
       }                                                         from a list.
    }
    

    output "timestamp" {
      value = local.time
    }

Ultimately this script will create 2 ec2 instance with 2 different tags.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Data Sources (Refer : https://www.terraform.io/docs/language/data-sources/index.html)
************
Data sources allow data to be fetched for use elsewhere in Terraform configuration. Eg. instead of hardcoding ami id,
we can use data source which will figureout the ami-id for the region specified based on other properties we pass.

So first create a data source / data block. Then use the data source in your resource section.

A data source is accessed via a special kind of resource known as a data resource, declared using a data block:

>>  vi data source.tf

    provider "aws" {
      region     = "ap-southeast-1"        <---------  based on changing this value, ami-id get picked up automatically.
      access_key = "YOUR-ACCESS-KEY"
      secret_key = "YOUR-SECRET-KEY"
    }

    data "aws_ami" "app_ami" {              ----|
      most_recent = true                        |
      owners = ["amazon"]                       |
                                                |
      filter {                                  |=====> Defining Data source
        name   = "name"                         |
        values = ["amzn2-ami-hvm*"]             |
      }                                         |
    }                                       ----|

    resource "aws_instance" "instance-1" {
       ami = data.aws_ami.app_ami.id           # Using the data source for the ami id.
       instance_type = "t2.micro"
    }


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Debugging in Terraform
**********************
Terraform has detailed log which can be enabled by setting up the TF_LOG environment variable to any value.

You can set TF_LOG to one of the log levels TRACE, DEBUG, INFO, WARN or ERROR to change the verbosity of the logs.

When you do terraform plan, you wouldnt see much logs since log levels are not set. So do the following.
>>  export TF_LOG=TRACE
>>  terraform plan

Now look at the log info that get printed out.

If you dont want to print the log info, then do the following.
>>  export TF_LOG_PATH=/tmp/crash.log

Now the logs are stored in the file which you can refer to find the error..

Also note TRACE is the most verbose and it is the default if TF_LOG is set to something other than a log level name.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Terraform Format
****************
To format your terraform script, use the following command
>>  terraform fmt
          OR
>>  Option + Shift + F in mac          


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Validating Terraform Configuration File
***************************************
. Terraform validate primarly checks whether a configuration is sytactically valid.
. It can check varous aspects including unsupported arguments, undeclared variables and others.

>>  vi script_with_error.tf

    provider "aws" {..}

    resource "aws_instance" "myec2" {
      ami           = "ami-082b5a644766e0e6f"
      instance_type = var.instancetype
      sky = "blue"
    }
    
>>  terraform init

>>  terraform validate
    │ Error: Unsupported argument
    │ 
    │   on validate.tf line 19, in resource "aws_instance" "myec2":
    │   19:   sky           = "blue"
    │ 
    │ An argument named "sky" is not expected here.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Load Order & Semantics
**********************
. Terraform generally loads all the configuration files within the directory specified in alphabetical order. 
. The files loaded must end in either .tf or .tf.json to specify the format that is in use.

Instead of writing everything in samescript, we can create seperate files for each section and move the script over there.

>>  mkdir load_order_semantics

>>  cd load_order_semantics

>>  create the following files
    . provider.tf                   <--   Move the provider section over here
    . variables.tf                  <--   Keep the variables defined here
    . ec2_resource.tf               <--   Resource section to create ec2 should be defined here
    . iam_user_resource.tf          <--   Resource section to create iam user should be in this file.
    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Dynamic Blocks (Refer : https://www.terraform.io/docs/language/expressions/dynamic-blocks.html)
**************
In many of the use-cases, there are repeatable nested blocks that need to be defined. This can lead to a long code and it 
can be difficult to manage in a long time.

eg. When ever you have security groups, you should have multiple ingress or egress blocks. Lets assume you need to add 14 
ports in your security group. So you need to create 14 ingress blocks with in your security group creation and that can be 
a bit of pain.

ingress {                                       ingress {
  from_port = 9200                                from_port = 8300
  to_port = 9200                                  to_port = 8300
  protocol = "tcp"                                protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]                     cidr_blocks = ["0.0.0.0/0"]
}                                               }
In the above block, the code is same, port is different.

Dynamic Blocks
--------------
Dynamic Block allows us to dynamically construct repeatable nested blocks which is supported inside resource, data, 
provider, and provisioner blocks:

dynamic "ingress" {
  for_each = var.ingress_ports          ===> port variable containing multiple ports
  content {
    from_port   = ingress.value                             
    to_port     = ingress.value                                
    protocol    = "tcp"                              
    cidr_blocks = ["0.0.0.0/0"]      
  }
}


Using Iterators
---------------
The iterator argument sets the name of a temporary variable that represents the current element of the complex value
If omitted, the name of the variable defaults to the label of the dynamic block ("ingress" in the example above).

dynamic "ingress" {                                            dynamic "ingress" {
  for_each = var.ingress_ports                                   for_each = var.ingress_ports
                                            -->                  iterator = port                 #using iterator
  content {                                                      content {
    from_port   = ingress.value                                    from_port   = port.value      #iterator key is used
    to_port     = ingress.value                                    to_port     = port.value         
    protocol    = "tcp"                                            protocol    = "tcp"                            
    cidr_blocks = ["0.0.0.0/0"]                                    cidr_blocks = ["0.0.0.0/0"]      
  }                                                              }
}                                                              } 


So Original Code
----------------
>>  vi before.tf

    resource "aws_security_group" "demo_sg" {
      name        = "sample-sg"

      ingress {
        from_port   = 8200
        to_port     = 8200
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
      }

      ingress {
        from_port   = 8201
        to_port     = 8201
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
      }

      ingress {
        from_port   = 8300
        to_port     = 8300
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
      }
    }


>>  vi dynamic_block.tf

    variable "sg_ports" {
      description = "list of ingress ports"
      type        = list(number)
      default     = [8200, 8201,8300]
    }

    resource "aws_security_group" "dynamicsg" {
      name        = "dynamic-sg"
      description = "Ingress for Vault"

      dynamic "ingress" {
        for_each = var.sg_ports
        iterator = port                         # iterator is defined as port
        content {
          from_port   = port.value              # hence port.value
          to_port     = port.value
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
        }
      }

      dynamic "egress" {
        for_each = var.sg_ports
        content {
          from_port   = egress.value            # iterator is not defined. hence using the dynamic block name.
          to_port     = egress.value
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
        }
      }
    }


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Tainting Resources (Refer : https://www.terraform.io/docs/cli/commands/taint.html)
******************
Understanding the Challenge
---------------------------
You have created a new resource via Terraform. Users have made a lot of manual changes (both infrastructure and inside the 
server)

Two ways to deal with this:  
. Import The Changes to Terraform : What changes users have made, we can import it to terraform.
. Delete & Recreate the resource  : Reverting to the original state by deleting the existing infra 
                                    first and then recreate the resources using the terraform file.

Overview of Terraform Taint
---------------------------
The terraform taint command manually marks a Terraform-managed resource as tainted, forcing it to be destroyed and recreated
on the next apply.

>>  vi taint.tf

    provider "aws" {...}

    resource "aws_instance" "myec2" {
       ami = "ami-082b5a644766e0e6f"
       instance_type = "t2.micro"
    }

Taint Command
-------------
>>  terraform taint aws_instance.myec2  --> now the resource is tainted which is updated in state file.

>>  terraform apply
    Plan: 1 to add, 0 to change, 1 to destroy   --> means the current tainted resource will be deleted and a new resource 
                                                    will be created. Also the taint status in state file will be removed.
    

Notes:
. This command will not modify infrastructure but does modify the state file in order to mark a resource as tainted. 
. Once a resource is marked as tainted, the next plan will show that the resource will be destroyed and recreated and 
  the next apply will implement this change.
. Note that tainting a resource for recreation may affect resources that depend on the newly tainted resource.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Splat Expressions (Refer : https://www.terraform.io/docs/language/expressions/splat.html)
*****************
Splat Expression '[*]' allows us to get a list of all the attributes. A splat expression provides a more concise way to 
express a common operation that could otherwise be performed with a for expression.

If var.list is a list of objects that all have an attribute id, then a list of the ids could be produced with the following 
for expression:
>>  [for o in var.list : o.id]

This is equivalent to the following splat expression:
>>  var.list[*].id

>>  vi splat.tf

    provider "aws" {...}
    
    # This resource will create 3 iam users.
    resource "aws_iam_user" "iam_users" {
      name  = "terra_user${count.index}"
      path  = "/system/"
      count = 3
    }

    # Print the usernames
    output "iam_usernames" {
      value = aws_iam_user.iam_users[*].name  --> [*] : splat expression which outputs the username of each users.
    }

    # Print the Amazon resource names.
    output "iam_arn" {
      value = aws_iam_user.iam_users[*].arn  --> [*] : splat expression which outputs the arn of each users.
    }
    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Terraform Graph (Refer : https://www.terraform.io/docs/cli/commands/graph.html)
***************
. The terraform graph command is used to generate a visual representation of either a configuration or execution plan.
. The output of terraform graph is in the DOT format, which can easily be converted to an image.

>>  Fist write your terraform script

>>  terraform graph > graph.dot

>>  yum install graphviz

>>  cat graph.dot | dot -Tsvg > graph.svg

>>  open graph.svg in chrome to see the pictorial representation.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Saving Terraform Plan to File 
*****************************
The generated terraform plan can be saved to a specific path.

This plan can then be used with terraform apply to be certain that only the changes shown in this plan are applied.

>>  Write you terrafrom script

>>  terraform plan -out=demoplanfile
    This will store the cuurent plan in the file demopath. Now even if someone update the script you committed, if you 
    have the plan file, then you can use and create the infra using it which you initially created. 

>>  terraform apply demoplanfile


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Terraform Output 
****************
The terraform output command is used to extract the value of an output variable from the state file.

>>  terraform output variable_name

Eg.
>>  vi terrafor_output.tf

    resource "aws_iam_user" "iam_users" {
      name  = "terra_user${count.index}"
      path  = "/system/"
      count = 3
    }

    # Print the usernames
    output "iam_usernames" {                              # output variable name : iam_usernames
      value = aws_iam_user.iam_users[*].name
    }

    # Print the Amazon resource names.
    output "iam_arn" {                                    # output variable name : iam_arn
      value = aws_iam_user.iam_users[*].arn
    }

>>  terraform init
>>  terraform plan
>>  terraform apply

Later if you want to know the value of variables, there are three ways.
1. terraform apply will show you the output values (arn and usernames)

2. Inspect the state file where you will be able to see the output variable with values.

3. Use terraform output command
Syntax : terraform output varibale_name
>>  terraform output iam_usernames        --> output variable names are defined in your terraform script
[
  "terra_user0",
  "terra_user1",
  "terra_user2",
]

>>  terraform output iam_arn        --> output variable names are defined in your terraform script
[
  "arn:aws:iam::989146945470:user/system/terra_user0",
  "arn:aws:iam::989146945470:user/system/terra_user1",
  "arn:aws:iam::989146945470:user/system/terra_user2",
]


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Terraform Settings
******************
The special terraform configuration block type is used to configure some behaviors of Terraform itself, such as requiring a 
minimum Terraform version to apply your configuration.

Terraform settings are gathered together into terraform blocks:
>>  terraform {
      # ...
      # ...      
    }

Setting 1 - Terraform Version
-----------------------------
The required_version setting accepts a version constraint string, which specifies which versions of Terraform can be used 
with your configuration.

If the running version of Terraform doesn't match the constraints specified, Terraform will produce an error and exit 
without taking any further actions.

>>  terraform {
      required_version = "> 0.12.0"
    }
    
Setting 2 - Provider Version
----------------------------
The required_providers block specifies all of the providers required by the current module, mapping each local provider name
to a source address and a version constraint.

>>  terraform {
      required_version = "< 0.11"         --> terraform version
      required_providers {
        aws = {
          source = "hashicorp/aws"
          version = "3.46.0"              --> provider version
        }
      }
    }


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Dealing with Large Infrastructure
*********************************
Watch the video

When you have a larger infrastructure, you will face issues related to API limits for a provider.
For. eg, say you did terraform plan on a infra.tf file containing 5EC2, 3RDS, 100 SG Rules and a VPC, when you do 
>>  terraform plan, it will do a refresh to update the state of each resource which causes so many API calls and 
you will face issues related to API limits for a provider.

So it is better to switch to a smaller configurations were each resource stay in seperate file & can be applied independently.

1. Setting Refresh to False
----------------------------
Also we can prevent terraform from querying  current state during operations like terraform plan, which can be achieved by
using the -refresh=false flag
>>  terraform plan -refresh=false

2. Specify the Target
---------------------
The -target=resource flag can be used to target a specific resource.
>>  terraform apply -target resource_type.resource.name

>>  vi infra.tf

    provider "aws" {..}

    module "vpc" {
      source = "terraform-aws-modules/vpc/aws"

      name = "my-vpc"
      cidr = "10.0.0.0/16"

      azs             = ["ap-southeast-1a", "ap-southeast-1b", "ap-southeast-1c"]
      private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
      public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

      tags = {
        Terraform = "true"
        Environment = "dev"
      }
    }

    resource "aws_security_group" "allow_ssh_conn" {
      name        = "allow_ssh_conn"
      description = "Allow SSH inbound traffic"

      ingress {
        description = "SSH into VPC"
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
      }
      ingress {
        description = "HTTP into VPC"
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
      }
      egress {
        description = "Outbound Allowed"
        from_port   = 0
        to_port     = 65535
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
      }
    }


    resource "aws_instance" "myec2" {
       ami = "ami-0b1e534a4ff9019e0"
       instance_type = "t2.micro"
       key_name = "ec2-key"
       vpc_security_group_ids  = [aws_security_group.allow_ssh_conn.id]
    }
    
Setting Refresh flag as false
-----------------------------
>>  terraform plan -refresh=false

Setting Refresh along with Target flags
---------------------------------------
>>  terraform plan -refresh=false -target=aws_security_group.allow_ssh_conn


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Zipmap Function 
***************
The zipmap function constructs a map from a list of keys and a corresponding list of values.

Pineapple                  Yellow                       Pineapple=Yellow
Mango            +         Orange      ---zipmap--->    Mango=Orange
Strawberry                 Red                          Strawberry=Red

List of Key                List of Value

>>  terform console
>>  zipmap(["pineapple","mango","strawberry"],["yellow","orange","red"])
    {
        "pineapple" = "yellow"   
        "mango" = "orange"
        "strawberry" = "red"
    }

Syntax : zipmap(keylist, valuelist)


Zipmap with a sample use-case
-----------------------------
. You are creating multiple IAM users.
. You need output which contains direct mapping of IAM names and ARNs

>>  zipmap.tf

    provider {...}

    # This resource will create 3 iam users.
    resource "aws_iam_user" "iam_users" {
      name  = "terra_user${count.index}"
      path  = "/system/"
      count = 3
    }

    # Print the usernames
    output "iam_usernames" {
      value = aws_iam_user.iam_users[*].name
    }

    # Print the Amazon resource names.
    output "iam_arn" {
      value = aws_iam_user.iam_users[*].arn
    }

    # Print the combination of resource names and arns
    output "combined" {
      value = zipmap(aws_iam_user.iam_users[*].name, aws_iam_user.iam_users[*].arn)
    }
    
Output
------
combined = {
  "terra_user0" = "arn:aws:iam::989146945470:user/system/terra_user0"
  "terra_user1" = "arn:aws:iam::989146945470:user/system/terra_user1"    --> this is what zipmap used for.
  "terra_user2" = "arn:aws:iam::989146945470:user/system/terra_user2"
}
iam_arn = [
  "arn:aws:iam::989146945470:user/system/terra_user0",
  "arn:aws:iam::989146945470:user/system/terra_user1",
  "arn:aws:iam::989146945470:user/system/terra_user2",
]
iam_usernames = [
  "terra_user0",
  "terra_user1",
  "terra_user2",
]
    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Terraform Provisioners (Refer : https://www.terraform.io/docs/language/resources/provisioners/syntax.html)
**********************
Understanding Provisioners in Terraform 
--------------------------------------- 
. Provisioners are used to execute scripts on a local or remote machine as part of resource creation or destruction.

Eg. After creating an EC2 instance, execute a script which installs the Nginx web server.

Refer : https://github.com/zealvora/terraform-beginner-to-advanced-resource/blob/master/Section%203%20-%20Terraform%20Provisioners/provisioner-types.md


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Types of Provisioners (Refer : https://www.terraform.io/docs/language/resources/provisioners/syntax.html)
**********************
Terraform has the capability to turn provisioners both at the time of resource creation as well as destruction. There are 
two main types of provisioners
1. local-exec
2. remote-exec

Local Exec Provisioners
-----------------------
. local-exec provisioners allow us to invoke a local executable after the resource is created.
. One of the most used approaches of local-exec is to run ansible-playbooks on the created server after the resource is 
  created.
  
Eg. resource "aws_instance" "web" {
 
      provisioner "local-exec" {                                            # This is executed locally.
          command = "echo ${aws_instance.web.private_ip} >> private_ip.txt
      }
    }
    
One of the real time use cases is execution of ansible playbooks.    


Remote Exec Provisioners
------------------------
. Remote-exec provisioners allow invoking scripts directly on the remote server.

Eg. resource "aws_instance" "web" {
      # …

      provisioner "remote-exec" {                                           # This is executed on remote machines.
        .........  
      }
    }


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Implementing remote-exec provisioners (Refer : https://www.terraform.io/docs/language/resources/provisioners/remote-exec.html)
*************************************
>>  vi remote-exec.tf

    terraform {..}

    provider "aws" {..}
    
    # Creating AWS instance
    resource "aws_instance" "MyAutomatedEC2" {
      ami           = "ami-0d5eff06f840b45e9"
      instance_type = "t2.micro"
      key_name      = "Terraform_Keys"                   -> Represent the name of the key pair to use for the instance.

      #Adding provisioner for exec commands in that EC2 instance
      provisioner "remote-exec" {
        inline = [                                       -> list of commands executed in the EC2 instance.
          "sudo amazon-linux-extras install -y nginx1.12",
          "sudo systemctl start nginx"
        ]

        connection {                                     -> Enable ssh access to the EC2 instance 
          type        = "ssh"                          
          user        = "ec2-user"
          private_key = file("./Terraform_Keys.pem")
          host        = self.public_ip
        }
      }
    }

    resource "aws_security_group" "allow_ssh" {          -> Adding a new security group resource to allow the terraform 
      name        = "allow_ssh"                             provisioner from laptop to connect to EC2 Instance via SSH.
      description = "Allow SSH inbound traffic"

      ingress {
        description = "SSH into VPC"
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
      }
      egress {
        description = "Outbound Allowed"
        from_port   = 0
        to_port     = 65535
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
      }
    }


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Implementing local-exec provisioners (Refer : https://www.terraform.io/docs/language/resources/provisioners/local-exec.html)
*************************************
Remote-exec execute the commandd in the remote instance. Eg. executing commands in the EC2 instance which is created where as
local-exec is used to exec command in our local machine.

Eg. executing ansible playbook from local machine.

>>  vi local_provisioner.tf

    terraform {..}

    provider "aws" {..}

    resource "aws_instance" "MyAutomatedEC2" {
      ami           = "ami-0d5eff06f840b45e9"
      instance_type = "t2.micro"

      provisioner "local-exec" {
        command = "echo ${self.private_ip} >> private_ips.txt"
      }
    }


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Creation-Time & Destroy-Time Provisioners 
*****************************************
Provisioner Types
-----------------
There are two primary types of provisioners:
. Creation Time Provisioner : It is only run once during creation and not subsequently during updating or any other 
                              lifecycle. If a creation time provisioner fails, the resource is marked as tainted.
                              
. Destroy Time Provisioner  : It runs before the resource is destroyed via terraform.

* If when = destroy is specified then the provisioner will run when the resource it is defined within is destroyed.

resource "aws_instance" "myec2" {
   ...

   provisioner "local-exec" {
     when = destroy                                   -> Destroy time provisioner
     command = "echo 'Destroy-time provisioner.'"
   }
}

>>  vi provisioner.tf

    terraform {..}

    provider "aws" {..}

    # Creating security group
    resource "aws_security_group" "allow_ssh" { 
      name        = "allow_ssh"
      description = "Allow SSH inbound traffic"

      # Creating ingress rule for allowing incoming traffic
      ingress {
        description = "SSH into VPC" 
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
      }

      # Creating outbound rule for connecting to internet to pull nano package
      egress {
        description = "Outbound Allowed" 
        from_port   = 0
        to_port     = 65535
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
      }
    }

    # Creating EC2 instance   
    resource "aws_instance" "myec2" { 
      ami                    = "ami-0ab4d1e9cf9a1215a"
      instance_type          = "t2.micro"
      key_name               = "Terraform_Keys"
      vpc_security_group_ids = [aws_security_group.allow_ssh.id]

      # Creation time provisioner
      provisioner "remote-exec" { 
        inline = [
          "sudo yum -y install nano"
        ]
      }

      # Destroy time provisioner (when = destroy)
      provisioner "remote-exec" { 
        when = destroy
        inline = [
          "sudo yum -y remove nano"
        ]
      }

      # SSH connection details for accessing the EC2 instance.
      connection { 
        type        = "ssh"
        user        = "ec2-user"
        private_key = file("./Terraform_Keys.pem")
        host        = self.public_ip
      }
    }


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Failure Behavior for Provisioners (Refer : https://www.terraform.io/docs/language/resources/provisioners/syntax.html#failure-behavior)
*********************************
By default, provisioners that fail will also cause the terraform apply itself to fail. 

The on_failure setting can be used to change this. The allowed values are:

|-----------------------|--------------------------------------------------------------------|
|   Allowed Values      |        Description                                                 |
|-----------------------|--------------------------------------------------------------------|
|   continue            |        Ignore the error and continue with creation or destruction  |
|                       |                                                                    |
|   fail                |        Raise an error and stop applying(the default behaviour).    |
|                       |        If this is a creation provisioner, taint the resource       |
|-----------------------|--------------------------------------------------------------------|

>>  vi on_failure.tf

    terraform {..}

    provider "aws" {..}

    # Creating security group
    resource "aws_security_group" "allow_ssh" {
      name        = "allow_ssh"
      description = "Allow SSH inbound traffic"

      # Creating ingress rule for allowing incoming traffic
      ingress {
        description = "SSH into VPC"
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
      }

      # No egress block, hence communicating to internet to download the nano package fails
    }

    # Creating EC2 instance   
    resource "aws_instance" "myec2" {
      ami                    = "ami-0ab4d1e9cf9a1215a"
      instance_type          = "t2.micro"
      key_name               = "Terraform_Keys"
      vpc_security_group_ids = [aws_security_group.allow_ssh.id]

      # Creation time provisioner
      provisioner "remote-exec" {
        on_failure = continue       # on failure condition.
        inline = [
          "sudo yum -y install nano"
        ]
      }

      # SSH connection details for accessing the EC2 instance.
      connection {
        type        = "ssh"
        user        = "ec2-user"
        private_key = file("./Terraform_Keys.pem")
        host        = self.public_ip
      }
    }
    
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Terraform Modules & Workspaces (Refer : https://www.terraform.io/docs/language/modules/develop/index.html)
******************************
Understanding DRY principle
---------------------------
In software engineering, don't repeat yourself (DRY) is a principle of software development aimed at reducing repetition of 
software patterns.

In the earlier lecture, we were making static content into variables so that there can be a single source of information.

                             |----  ${var.source}                          
                             |
116.75.30.50  -->  Source ---|----  ${var.source}
                             |
                             |----  ${var.source}
                             
. What this means is that let say you have 3 places where you used the resource block for creating EC2 instance. Instead of 
  writing same set of code, write once and use many.

Generic Scenario
----------------
We do repeat multiple times various terraform resources for multiple projects.

Eg. Sample EC2 Resource        ->         resource "aws_instance" "myweb" {
                                             ami = "ami-bf5540df"
                                             instance_type = "t2.micro"
                                             security_groups = ["default"]
                                          }

Instead of repeating a resource block multiple times, we can make use of a centralized structure.

Centralized Structure
---------------------
We can centralize the terraform resources and can call out from TF files whenever required.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Implementing EC2 module with Terraform
**************************************
Watch the video and code in VSC.

https://www.udemy.com/course/terraform-beginner-to-advanced/learn/lecture/15725316#questions

Variables and Terraform Modules
*******************************
Watch the video and code in VSC.

https://www.udemy.com/course/terraform-beginner-to-advanced/learn/lecture/15725344#questions


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Terraform Registry (Refer : https://registry.terraform.io/)
******************
. The Terraform Registry is a repository of modules written by the Terraform community. 
. The registry can help you get started with Terraform more quickly

Module Location
---------------
. If we intend to use a module, we need to define the path where the module files are present.
. The module files can be stored in multiple locations, some of these include:
  > Local Path
  > GitHub
  > Terraform Registry
  > S3 Bucket
  > HTTP URLs

Using Registry Modules in Terraform
-----------------------------------
. To use Terraform Registry module within the code, we can make use of the source argument that contains the module path.
. Below code references to the EC2 Instance module within terraform registry.

  module "ec2-instance" {
    source  = "terraform-aws-modules/ec2-instance/aws"
    version = "2.19.0"
    # insert the 10 required variables here
  }  

>>  vi my_ec2_using_registry.tf

    terraform {..}

    provider "aws" {..}

    module "ec2-instance" {                                           # copied the block from registry and added required 
      source  = "terraform-aws-modules/ec2-instance/aws"                values.
      version = "2.19.0"

      name                   = "my-cluster"
      instance_count         = 1
      ami                    = "ami-0ab4d1e9cf9a1215a"
      instance_type          = "t2.micro"
      subnet_id              = "subnet-9e073090"                      # copied the default value

      tags = {
        Terraform   = "true"
        Environment = "dev"
      }
    }

Refer EC2 module from registry : https://registry.terraform.io/modules/terraform-aws-modules/ec2-instance/aws/latest

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Terraform Workspace (Refer : https://www.terraform.io/docs/language/state/workspaces.html)
*******************
Terraform allows us to have multiple workspaces, with each of the workspaces we can have a different set of environment 
variables associated.

 |-------------------|
 |    |---------|    |
 |    |  Stage  |  --|--> instance_type = t2.micro
 |    |---------|    |
 |                   |
 |                   |
 |    |---------|    |
 |    |  Prod   |  --|--> instance_type = t2.large
 |    |---------|    |
 |-------------------|    
    
. Terraform starts with a single workspace named "default".

. This workspace is special both because it is the default and also because it cannot ever be deleted.

. If you've never explicitly used workspaces, then you've only ever worked on the "default" workspace.

. Workspaces are managed with the terraform workspace set of commands. 

. To create a new workspace and switch to it, you can use terraform workspace new; to switch workspaces 
  you can use terraform workspace select; etc.
  
Terraform Workspace commands:
----------------------------
>>  terraform workspace -h

>>  terraform workspace show        : show the name of current workspace

>>  terraform workspace new dev     : create a new workspace dev

>>  terraform workspace new prd     : create a new workspace prd

>>  terraform workspace list        : list all workspace.

>>  terraform workspace select dev  : switch to dev workspace

First create 3 workspace. default will be there automatically and lets create dev and prd.
>>  mkdir workspace
>>  cd workspace
>> touch workspace.tf                 # created the directory and terraform file.

>>  terraform workspace new dev
>>  terraform workspace new prd       # created dev n prd workspaces.

>>  vi workspace.tf

    terraform {..}

    provider "aws" {..}

    resource "aws_instance" "MyAutomatedEC2" {
      ami           = "ami-0d5eff06f840b45e9"
      instance_type = lookup(var.instance_type, terraform.workspace)   # Based on the workspace, it will 
    }                                                                  # pick up value for instance type.

    variable "instance_type" {
      type = map(string)

      default = {
        default = "t2.nano"
        dev     = "t2.micro"
        prd     = "t2.large"
      }
    }

>>  terraform workspace select default
>>  terraform init
>>  terraform plan -----------------> look at the instance type. you will see t2.nano

>>  terraform workspace select dev
>>  terraform plan -----------------> look at the instance type. you will see t2.micro

>>  terraform workspace select prd
>>  terraform plan -----------------> look at the instance type. you will see t2.large


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Remote State Management (Refer : https://www.terraform.io/docs/language/state/workspaces.html)
***********************
Integrating with GIT for team management
----------------------------------------
Till now, we have been working with terraform code locally. However, storing your configuration files locally is not always 
an idea specifically in the scenario were other members of the team are also working on Terraform.

For such cases, it is important to store your Terraorm code to a centralized repository like in Git.

Note : While committing data to the Git repository,  please avoid pushing your access/secret keys with the code. 
       This is very important.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Security Challenges in Commiting TFState to GIT
************************************************
Even if you store passwords in a different file, and wont commit it along with .tf files, if you push terraform.tfstate 
file, then will contain the passwords. 

So better avoid pushing terraform.tfstate file.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Module Sources in Terraform (Refer : https://www.terraform.io/docs/language/modules/sources.html)
***************************
The source argument in a module block tells Terraform where to find the source code for the desired child module.

. Local paths
. Terraform Registry
. GitHub
. Bitbucket
. Generic Git, Mercurial repositories
. HTTP URLs
. S3 buckets
. GCS buckets


Local Path
----------
A local path must begin with either ./ or ../ to indicate that a local path is intended.

module "consul" {
  source = "../consul"
}


Git Module Source
-----------------
. Arbitrary Git repositories can be used by prefixing the address with the special git:: prefix. 
. After this prefix, any valid Git URL can be specified to select one of the protocols supported by Git(https & ssh).

module "vpc" {
  source = "git::https://example.com/vpc.git"
}

module "storage" {
  source = "git::ssh://username@example.com/storage.git"
}


Referencing to a Branch
-----------------------
. By default, Terraform will clone and use the default branch (referenced by HEAD) in the selected repository. 
. You can override this using the ref argument:

module "vpc" {
  source = "git::https://example.com/vpc.git?ref=v1.2.0"            --> tag
}

                OR
                
module "vpc" {
  source = "git::https://example.com/vpc.git?ref=development"       --> branch
}                

The value of the ref argument can be any reference that would be accepted by the git checkout command, including branch and 
tag names.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Terraform and .gitignore
************************
. The .gitignore file is a text file that tells Git which files or folders to ignore in a project.
. Depending on the environment, it is recommended to avoid committing certain files to GIT.

File to Ignore                      Description
--------------                      -----------
.terraform                          This file will be recreated when terraform init is run
terraform.tfvars                    Ignore if it contain sensitive data like username/password n secrets
terraform.tfstate                   Should be stored in the remote side
crash.log                           If terraform crashes, the logs are stored to a file named crash.log


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Remote State Management with Terraform (Refer : https://www.terraform.io/docs/language/settings/backends/remote.html)
**************************************
. Since the terraform.tfstate file  contain sensitive information. So it is recommended to avoid commiting the .tfstate 
  file to Git and the alternate way to use .tfstate file is using Remote Backend, which is basically a feature of terraform,
  which allows you to store terraform.tfstate files in a central repository which is not GIT.

. Terraform supports various types of remote backends to store state data.

. Depending on remote backends that are being used,  there can be various features.
  > Standard BackEnd Type:    State Storage and Locking
  > Enhanced BackEnd Type:  All features of Standard + Remote Management

. In the ideal scenario, your terraform configuration code should be part of the GIT repositories and state file should be 
  part of the remote backends

. So to configure this, while writing the terraform script, we need to add one more file called backend.tf which contains
  info about the remote backend.
  
. One of the supported backend type is S3 and another examples include 
  > artifactory  > azurerm  > consul  > cos  
  > etcd         > etcdv3   > gcs     > http  
  > kubernetes   > manta    > oss     > pg  
  > s3           > swift


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Implementing S3 Backend (Refer : https://www.terraform.io/docs/language/settings/backends/s3.html)
***********************
So for this we create 3 terraform script.
1. for aws provider
2. for resource creation
3. for storing the .tfstate file in a s3 bucket.

>>  vi provider.tf                           --> provider script

    terraform {..}

    provider "aws" {
      region     = "us-east-1"
      access_key = "*************"
      secret_key = "*************"
    }


>>  vi ec2.tf                               --> resource script

    resource "aws_eip" "myeip" {
      vpc = "true"
    }


>>  vi remote-backend.tf                    --> for storing the .tfstate in remote backend.(here its s3.)

    terraform {
      backend "s3" {
        bucket         = "terraform-remote-backend-storage"
        key            = "eip.tfstate"                              # name of .tfstate file.
        region         = "us-east-1"
        access_key     = "AKIA6MTOAS67E44UU65R"
        secret_key     = "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"
      }
    }

After executing the command terraform apply, you will notice that the .tfstate file is not generated. So if you go look 
at the s3 bucket, you will be able to see the .tfstate file in your s3 bucket


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Challenges with State File locking
**********************************
Whenever you are performing a write operation(terraform plan), terraform would lock the state file. This is very important 
as otherwise during your ongoing terraform apply operations, if others also try for the same, it would corrupt your state 
file.

Example:
. Person A is terminating the RDS resource which has associated rds.tfstate file
. Person B has now tried resizing the same RDS resource at the same time.

For the S3 backend, you can make use of the DynamoDB for state file locking functionality.

For eg. if you do terraform plan from two terminal, in one of the window, you will get the following error.
>> terraform plan
   ╷
   │ Error: Error acquiring the state lock
   │ 
   │ Error message: resource temporarily unavailable
   
Note that this kind of locking feature is not available for all the remote backendtype. So if you store the .tfstate file 
directly in the s3, the locking feature wont be available and ultimately it could corrupt the .tfstate file if two people 
concurrently execute some write operations.

So whatever backend type you choose, you should make sure that the locking functionality is available else the .tfstate file
get corrupted.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Integrating DynamoDB with S3 for state locking (Refer : https://www.terraform.io/docs/language/settings/backends/s3.html)
**********************************************
. By default if you are using S3 for remote backend, it wont support state locking.
. For the S3 backend, you can make use of the DynamoDB for state file locking functionality.

Create the following first.
1. S3 Bucket 
2. Dynamo DB in aws with the name mentioned in the script.

S3 Bucket
---------
>>  Amazon S3 --> Create Bucket
>>  Bucket Name : terraform-remote-backend-storage
>>  AWS Region : us-east-1
>>  Click Create Bucket

Dynamo DB (Refer : https://www.terraform.io/docs/language/settings/backends/s3.html#dynamodb-state-locking)
---------
>>  Dynamo DB --> Create Table 
>>  Table Name : terraform_remote_backend_state_lock
>>  Primary Key : LockID
>>  Type : String


Now create the following three terraform script.
1. for aws provider
2. for resource creation
3. for storing the .tfstate file in a s3 bucket.

>>  vi provider.tf                           --> provider script

    terraform {..}

    provider "aws" {
      region     = "us-east-1"
      access_key = "*************"
      secret_key = "*************"
    }

>>  vi ec2.tf                               --> resource script

    resource "aws_eip" "myeip" {
      vpc = "true"
    }

>>  vi remote-backend.tf                    --> for storing the .tfstate in remote backend.(here its s3.)

    terraform {
      backend "s3" {
        bucket         = "terraform-remote-backend-storage"         # S3 BUCKET NAME
        key            = "eip.tfstate"                              # NAME OF .tfstate FILE CREATED IN S3 BUCKET.
        region         = "us-east-1"
        access_key     = "AKIA6MTOAS67E44UU65R"
        secret_key     = "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"
        dynamodb_table = "terraform_remote_backend_state_lock"      # NAME OF THE DYNAMO DB TABLE
      }
    }
    
>>  terraform init
>>  terraform plan
Now you will see lock file get created in the dynamo db table. To see that, do the folllowing

>>  Dyanmo DB --> Items 
>>  terraform plan       on you script directory
>>  click refresh button on Dynamo DB items tab
>>  You will see the lock file with name "terraform-remote-backend-storage/eip.tfstate"

After executing the command terraform apply, you will notice that the .tfstate file is not generated. So if you go look 
at the s3 bucket, you will be able to see the .tfstate file in your s3 bucket and the lock file in the dynamo db.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Terraform State Management (Refer : https://www.terraform.io/docs/cli/commands/state/index.html)
**************************
There are some cases where you may need to modify the Terraform state and it is important to never modify the state file 
directly and manually. Instead, make use of terraform state command.

There are multiple sub-commands that can be used with terraform state, these include

State Sub Command                Description
-----------------                -----------
. list                           List resources with terraform state file               
. mv                             Moves item with terraform state
. pull                           Manually download and output the state from remote state
. push                           Manually upload a local state file to remote state
. rm                             Remove items from the Terraform state
. show                           Show the attrobutes of a single resource in the state


List
----
The terraform state list command is used to list resources within a Terraform state.
>>  terraform state list
    aws_iam_user.lb
    aws_instance.weapp
    
    
Move
----
. The terraform state mv command is used to move items in a Terraform state. 
. This command is used in places where you want to rename an existing resource without destroying and recreating it.
. Due to the destructive nature of this command, this command will output a backup copy of the state prior to saving any 
  changes

So lets say you have an ec2 instance with name myEC2 and you need to rename it to TerraEC2. If you do manually, and when you do 
terraform plan, it will delete the current EC2 instance and create new instance iwth the updated name. Instead of this
we can update the current EC2 instance name with terraform state mv command.
>>  terraform state mv [options] SOURCE DESTINATION
Eg. terraform state mv aws_instance.myEC2 aws_instance.terraEC2
    

Pull
----
. The terraform state pull command is used to manually download and output the state from a remote state.
. This is useful for reading values out of state (potentially pairing this command with something like jq).
>>  terraform state pull
>>  terraform state pull aws_instance.terraEC2
    {
      "version": 4,
      "terraform_version": "0.15.5",
      ...
      ...
    }


Push
----
. The terraform state push command is used to manually upload a local state file to remote state.
. This command should rarely be used.


Remove
------
. The terraform state rm command is used to remove items from the Terraform state.
. Items removed from the Terraform state are not physically destroyed. 
. Items removed from the Terraform state are only no longer managed by Terraform

Eg. if you remove an AWS instance from the state, the AWS instance will continue running, but terraform plan will 
    no longer see that instance.
>>  terraform state rm resource_type.resource_name
Eg. terraform state rm aws_instance.TerraEC2      ->  this is removed from the state file but the instance will 
    Removed aws_instance.TerraEC2                     be still running
    Successfully removed 1 resource instance(s).

>>  terraform state pull                          ->  Now do a pull, you wouldnt see any output since it is removed 
                                                      from state file.
  
Show
----
The terraform state show command is used to show the attributes of a single resource in the Terraform state.
>>  terrafrom state show resource_type.resource_name
Eg. terrafrom state show aws_instance.TerraEC2

    resource "aws_instance" "TerraEC2" {
        ami                                  = "ami-0d5eff06f840b45e9"
        ...
        ...
    }

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Importing Existing Resources with Terraform Import (Refer : https://www.terraform.io/docs/cli/import/index.html)
**************************************************
It might happen that there is a resource that is already created manually. In such a case, any change you want to make to 
that resource must be done manually.

Terraform is able to import existing infrastructure. This allows you to take resources you've created by some other means 
and bring it under Terraform management.

The current implementation of Terraform import can only import resources into the state. It does not generate configuration.
A future version of Terraform will also generate configuration.

Because of this, prior to running terraform import it is necessary to write manually a resource configuration block for the 
resource, to which the imported object will be mapped.

The current implementation of Terraform import can only import resources into the state. It does not generate configuration.
A future version of Terraform will also generate configuration.

Because of this, prior to running terraform import it is necessary to write manually a resource configuration block for the 
resource, to which the imported object will be mapped.

>>  mkdir terraform_import

>>  cd terraform_import

>>  vi provider.tf

    terraform {..}

    provider "aws" {
      region     = "us-east-1"
      access_key = "*****************"
      secret_key = "*****************"
    }
    
Please note that terraform will generate the .tfstate file for you and not the .tf file.

>>  vi myec2.tf                                           -> The info is copied from the existing info running on EC2

    resource "aws_instance" "MyAutomatedEC2" {
      ami                    = "ami-0d5eff06f840b45e9"
      instance_type          = "t2.micro"
      vpc_security_group_ids = ["sg-sg-021ea407"]
      subnet_id              = "subnet-1f63e22e"
    }


>>  terraform init

>>  terrform plan                                         -> Ensure no errors are thrown.

>>  terraform import aws_instance.MyAutomatedEC2 i-0f183b7c2df5b210a
                                                          |
                                                          |-> Instance ID copied from AWS EC2 dashboard


>> terraform.tfstate file is imported now.

Now the EC2 info is available, lets add a new security group id under the myec2.tf, then do the following.

>>  terraform plan                                        -> you will notice the changes

>>  terraform apply                                       -> go check the ec2 instance in aws and you  
                                                             will see the newly added security group.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Security Primer (Refer : https://www.terraform.io/docs/language/providers/configuration.html)
***************
Handling Access & Secret Keys the Right Way in Providers
--------------------------------------------------------
Currently when we write terrafrom script, in providers.tf we entered the secret key and access key. This is not a good
practice since when we commit and push code to git, there is chance for these secrets to be compramised. To avoid this, 
setup aws cli and so you don't need to share any secret key or acces key in your providers.tf file.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Terraform Provider UseCase - Resources in Multiple Regions
**********************************************************
Till now, we have been hardcoding the aws-region parameter within the providers.tf

This means that resources would be created in the region specified in the providers.tf file

    resource "myec201"  ------>   us-east-1
    resource "myec202"  ------>   ap-south-1
    
By default, resources use a default provider configuration inferred from the first word of the resource type name. 

For eg, a resource of type aws_instance uses the default (un-aliased) aws provider configuration unless otherwise stated.

To select an aliased provider for a resource or data source, set its provider meta-argument to a <PROVIDER NAME>.<ALIAS> 
reference:

resource "aws_eip" "eip2" {
  vpc = "true"           
  provider = "aws.aws02"                   #   -> aws.alias_name
}

>>  vi provider.tf

    terraform {..}


    provider "aws" {
      alias  = "virginia"              # No need to add the alias for the default provider. I just add it for fum
      region = "us-east-1"
    }

    provider "aws" {
      alias  = "mumbai"                # Should add the alias for the second aws provider.
      region = "ap-south-1"
    }
    
>>  vi eip.tf

    resource "aws_eip" "eip1" {
      vpc      = "true"       #   -> Deploy this in us-east1
      provider = aws.virginia #   -> aws.alias_name           Note. no need to add provider for the first/default resource
    }

    resource "aws_eip" "eip2" {
      vpc      = "true"     #   -> Deploy this in ap-south-1
      provider = aws.mumbai #   -> aws.alias_name
    }

When you run the terraform apply, elastic ip is created in multiple regions.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Handling Multiple AWS Profiles with Terraform Providers
*******************************************************
So if you want to create same or different resources in different regions owned by different account, do the following.

>>  vi provider.tf

    terraform {..}


    provider "aws" {
      region = "us-east-1"
    }

    provider "aws" {
      alias  = "mumbai"                # Should add the alias for the second aws provider.
      region = "ap-south-1"
      profile = "account02"            # Assume account02 is the second aws user account configured via aws cli
    }                                  # in .aws/credentials
    
>>  vi eip.tf

    resource "aws_eip" "eip1" {
      vpc      = "true"       #   -> Deploy this in us-east1
    }

    resource "aws_eip" "eip2" {
      vpc      = "true"     #   -> Deploy this in ap-south-1
      provider = aws.mumbai #   -> aws.alias_name
    }

This will create one elastic ip in us-east-1 under the default user account and the second elastic ip in ap-south-1 under 
the account02 aws user account.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Terraform & Assume Role with AWS STS (Refer : https://registry.terraform.io/providers/hashicorp/aws/latest/docs#assume-role)
************************************

Watch the video : https://www.udemy.com/course/terraform-beginner-to-advanced/learn/lecture/10053246#overview


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Sensitive Parameter (Refer : https://learn.hashicorp.com/tutorials/terraform/sensitive-variables)
*******************
With the organization managing its entire infrastructure in terraform, it is likely that you will see some sensitive 
information embedded in the code. 

When working with a field that contains information likely to be considered sensitive, it is best to set the Sensitive 
property on its schema to true

output "db_password" {
  value         = aws_db_instance.db_password
  description   = "The password for logging into the database"
  sensitive     = true
}

Setting the sensitive to “true” will prevent the field's values from showing up in CLI output and in Terraform Cloud

It will not encrypt or obscure the value in the state, however.

>>  terraform apply
Apply complete! resources: 0 added, 0 changed, 0 destroyed
Outputs:
db_password = <sensitive>


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Terraform Cloud & Enterprise Capabilities
*****************************************
Overview of Terraform Cloud (refer : https://www.terraform.io/cloud)
---------------------------
. Terraform Cloud manages Terraform runs in a consistent and reliable environment with various features like access controls, 
  private registry for sharing modules, policy controls, and others.

. Terraform Cloud is available as a hosted service at https://app.terraform.io.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Creating Infrastructure with Terraform Cloud
********************************************
Talks about how to setup terraform cloud, integrating it with github and how to run your script etc.

<<<<<< Watch the video >>>>>>>>>>


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Overview of Sentinel (Refer : https://docs.hashicorp.com/sentinel/terraform)
********************
. Sentinel is an embedded policy-as-code framework integrated with the HashiCorp Enterprise products. 
. It enables fine-grained, logic-based policy decisions, and can be extended to use information from external sources.
. Sentinel policies are paid feature 

                        terraform plan --> sentinel checks --> terraform apply
                        
Lets say that you wanted to ensure any resources you created in aws should have a tag. So when you do terraform plan via
terraform cloud, it will do a sentinel check where a policy for checking the tag should be added, which will check whether 
any tag has been added or not. if not added, then it will fail and the terraform apply/infrastrucure creation won't happen.

Sample Sentinel Policy : For tag checks
----------------------
import "tfplan"
 
main = rule {
  all tfplan.resources.aws_instance as _, instances {
    all instances as _, r {
      (length(r.applied.tags) else 0) > 0
    }
  }
}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Overview of Remote Backends
***************************
> Terraform supports various types of remote backends which can be used to store state data.
> As of now, we were storing state data in local and GIT repository.
> Depending on remote backends that are being used,  there can be various features.
  . Standard BackEnd Type:  State Storage and Locking
  . Enhanced BackEnd Type:  All features of Standard + Remote Management

When using full remote operations, operations like terraform plan or terraform apply can be executed in Terraform Cloud's 
run environment, with log output streaming to the local terminal. 

Remote plans and applies use variable values from the associated Terraform Cloud workspace.

Terraform Cloud can also be used with local operations, in which case only state is stored in the Terraform Cloud backend.

<<<<<< Watch the video >>>>>>>>>>


Implementing Remote Backend Operations in Terraform Cloud
---------------------------------------------------------
<<<<<< Watch the video >>>>>>>>>>


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Exam Preparation Section
************************
Source: https://gist.github.com/vsathyak


