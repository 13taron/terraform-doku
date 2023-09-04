provider "aws" {
  #shared_credentials_file = "C:\Users\Taron\.aws\credentials"
  region                = "eu-north-1"
#  access_key            = "****************"                    
#  secret_key            = "******************"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "4.0.1"

  name                = var.vpc_name
  cidr                = var.vpc_cidr           
  azs                 = var.azs
  private_subnets     = var.private_subnet_cidrs
  public_subnets      = var.public_subnet_cidrs

}

module "ec2_security_group" {
  source      = "terraform-aws-modules/security-group/aws"
  version     = "4.17.2"
  name        = var.name_sg
  vpc_id      = module.vpc.vpc_id

  ingress_with_cidr_blocks = [
    {
    description = "SSH from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = "0.0.0.0/0"
     },
     {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 2049
      to_port     = 2049
      protocol    = "tcp"
      description = "EFS mount target"
      cidr_blocks = "0.0.0.0/0"
    }
    ]
  egress_rules = ["all-all"]

}

module "ec2-instance1" {
  source                      = "terraform-aws-modules/ec2-instance/aws"
  version                     = "4.3.0"
  
  ami                         =  var.ami_id
  instance_type               =  var.instance_type
  vpc_security_group_ids      =  [module.ec2_security_group.security_group_id]
  subnet_id                   =  module.vpc.public_subnets[0]
  associate_public_ip_address = true
  key_name                    =  var.key_name
  user_data                   = <<-EOF
        #!/bin/bash

        sudo apt-get update -y  && sudo apt-get upgrade -y
        sudo apt-get install apache2 libapache2-mod-php php-xml -y
        sudo a2enmod rewrite 
        cd /var/www
        sudo wget https://download.dokuwiki.org/src/dokuwiki/dokuwiki-stable.tgz 
        sudo tar xvf dokuwiki-stable.tgz
        sudo mv dokuwiki-*/ dokuwiki
        sudo chown -R www-data:www-data /var/www/dokuwiki
        sudo sed -i 's|DocumentRoot /var/www/html|DocumentRoot /var/www/dokuwiki|g' /etc/apache2/sites-enabled/000*.conf
        sudo sed -i '169,174 s|AllowOverride None|AllowOverride All|g' /etc/apache2/apache2.conf                                         
        sudo systemctl restart apache2.service
        sudo cp -r /var/www/dokuwiki/data /home/ubuntu/data
        sudo rm -r /var/www/dokuwiki/data
        sudo apt-get -y install nfs-common
        sudo mkdir /var/www/dokuwiki/data
        sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport ${module.efs.dns_name}:/ /var/www/dokuwiki/data    
        sudo cp -r /home/ubuntu/data/ /var/www/dokuwiki/
        sudo chown -R www-data:www-data /var/www/dokuwiki/data
                        EOF
  tags = {
    Name = "Dokuwiki 1"
  }
}

module "ec2-instance2" {
  source                       = "terraform-aws-modules/ec2-instance/aws"
  version                      = "4.3.0"
  
  ami                          = var.ami_id
  instance_type                = var.instance_type
  vpc_security_group_ids       =  [module.ec2_security_group.security_group_id]
  subnet_id                    =  module.vpc.public_subnets[0]
  associate_public_ip_address  = true
  key_name                     = "doku-2"
  user_data                    = <<-EOF
        #!/bin/bash

        sudo apt-get update -y  && sudo apt-get upgrade -y
        sudo apt-get install apache2 libapache2-mod-php php-xml -y
        sudo a2enmod rewrite 
        cd /var/www
        sudo wget https://download.dokuwiki.org/src/dokuwiki/dokuwiki-stable.tgz 
        sudo tar xvf dokuwiki-stable.tgz
        sudo mv dokuwiki-*/ dokuwiki
        sudo chown -R www-data:www-data /var/www/dokuwiki
        sudo sed -i 's|DocumentRoot /var/www/html|DocumentRoot /var/www/dokuwiki|g' /etc/apache2/sites-enabled/000*.conf
        sudo sed -i '169,174 s|AllowOverride None|AllowOverride All|g' /etc/apache2/apache2.conf                                         
        sudo systemctl restart apache2.service
        sudo cp -r /var/www/dokuwiki/data /home/ubuntu/data
        sudo rm -r /var/www/dokuwiki/data
        sudo apt-get -y install nfs-common
        sudo mkdir /var/www/dokuwiki/data
        sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport ${module.efs.dns_name}:/ /var/www/dokuwiki/data    
        sudo cp -r /home/ubuntu/data/ /var/www/dokuwiki/
        sudo chown -R www-data:www-data /var/www/dokuwiki/data
                        EOF
                      
  tags = {
     Name = "Dokuwiki 2"
   }
}

module "efs" {
  source             = "terraform-aws-modules/efs/aws"
  version            = "1.1.1"

  name               = var.name_efs
  creation_token     = var.creation_token_efs
  encrypted          = false
  throughput_mode    = var.throughput_mode
  performance_mode   = var.performance_mode
  attach_policy      = false

  # Mount targets / security group
  mount_targets        = {
    "eu-north-1a"      = {
      subnet_id        = module.vpc.public_subnets[0]
    }
  }
  security_group_description = var.sg_name_efs
  security_group_vpc_id      = module.vpc.vpc_id
  security_group_rules       = {
    ingress_rules = {
      type        = "ingress"
      from_port   = 2049
      to_port     = 2049
      protocol    = "tcp"
      cidr_blocks = ["10.0.1.0/24"]
    }
    egress_rules  = {
      type        = "egress"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
    }

  tags = {
    Name = "EFS Security group"
    Terraform   = "true"
    Environment = "dev"
  }
}

# module "alb" {
#   source  = "terraform-aws-modules/alb/aws"
#   version = "8.6.0"

#   name = var.name_alb
#   load_balancer_type = "application"

#   vpc_id  = module.vpc.vpc_id
#   subnets = module.vpc.public_subnets
  
#  #noric nayi security_groups = [module.vpc.default_security_group_id]
  
#   security_group_rules = {
#     ingress_all_http = {
#       type        = "ingress"
#       from_port   = 80
#       to_port     = 80
#       protocol    = "tcp"
#       description = "HTTP web traffic"
#       cidr_blocks = ["0.0.0.0/0"]
#     }
#     egress_all = {
#       type        = "egress"
#       from_port   = 0
#       to_port     = 0
#       protocol    = "-1"
#       cidr_blocks = ["0.0.0.0/0"]
#     }
#   }
    
#   http_tcp_listeners = [
#     # Forward action is default, either when defined or undefined
#     {
#       port               = 80
#       protocol           = "HTTP"
#       target_group_index = 0
#       action_type        = "forward"
      
#     }
#   ]

#   target_groups = [
#     {
#       #name_prefix                       = var.name_prefix
#       backend_protocol                  = "HTTP"
#       backend_port                      = 80
#       target_type                       = "instance"

#       health_check = {
#         enabled             = true
#         interval            = 30
#         path                = "/"
#         port                = "traffic-port"
#         healthy_threshold   = 3
#         unhealthy_threshold = 3
#         timeout             = 6
#         protocol            = "HTTP"
#       }
#       protocol_version = "HTTP1"
#       targets = {
#         first_ec2 = {
#           target_id = module.ec2-instance1.id
#           port      = 80
#         },
#         second_ec2 = {
#           target_id = module.ec2-instance2.id
#           port      = 80
#         }
#       }

#       tags = {
#         InstanceTargetGroupTag = "baz"
#       }
#     }
#   ]

#   tags = {
#     Project = "Dokuwiki"
#   }

#   lb_tags = {
#     MyLoadBalancer = "ALB-Doku"
#   }

#   target_group_tags = {
#     MyGlobalTargetGroupTag = "Ec2-doku"
#   }
# }





