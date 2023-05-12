################
# VPC VARIABLES#
################

variable "vpc_name" {
  description = "Name to be used on all the resources as identifier"
  type        = string
  default     = "vpc"
}

variable "vpc_cidr" {
  description = "(Optional) The IPv4 CIDR block for the VPC. CIDR can be explicitly set or it can be derived from IPAM using `ipv4_netmask_length` & `ipv4_ipam_pool_id`"
  type        = string
  default     = "10.0.0.0/16"
}

variable "azs" {
  description = "A list of availability zones names or ids in the region"
  type        = list(string)
  default     = ["eu-north-1a", "eu-north-1b","eu-north-1c"]
}

variable "public_subnet_cidrs" {
 type        = list(string)
 description = "Public Subnet CIDR values"
 default     = ["10.0.1.0/24", "10.0.5.0/24"]
}
 
variable "private_subnet_cidrs" {
 type        = list(string)
 description = "Private Subnet CIDR values"
 default     = ["10.0.4.0/24"]
}

##########################
#SECURITY GROUP VARIABLES#
##########################
variable "name_sg" {
  type    = string
  default = "security-group"
}

variable "vpc_id" {
  type    = string
  default = null
}

variable "ingress_rules_ec2" {
  description      = "List of ingress rules to allow SSH and HTTP(+EFS)"
  type             = list(object({
  description      = string
  from_port        = number
  to_port          = number
  protocol         = string
  security_groups  = list(string)
  cidr_blocks      = list(string)
  }))

   default  = [
    {
      description      = "Allow SSH inbound traffic"
      from_port        = 22
      to_port          = 22
      protocol         = "tcp"
      security_groups  = []
      cidr_blocks      = ["10.0.0.0/16"]
    },
    {
      description      = "Allow HTTP inbound traffic"
      from_port        = 80
      to_port          = 80
      protocol         = "tcp"
      security_groups  = []
      cidr_blocks      = ["0.0.0.0/0"]
    },
    {
      description      = "EFS mount target"
      from_port        = 2049
      to_port          = 2049
      protocol         = "tcp"
      security_groups  = []
      cidr_blocks      = ["0.0.0.0/0"]
    }
  ]
}

variable "egress_rules_ec2" {
  description       = "List of egress rules to allow all trafic out"
    type            = list(object({
    description     = string
    from_port       = number
    to_port         = number
    protocol        = string
    security_groups = list(string)
    cidr_blocks     = list(string)
  }))

  default = [
    {
      description      = "Allow all outbound traffic"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      security_groups  = []
      cidr_blocks      = ["0.0.0.0/0"]
    }]
}
################
# EC2 VARIABLES#
################

variable "instance_type" {
  description = "The type of EC2 instance to launch"
  default = "t3.micro"
  type        = string
}

variable "ami_id" {
  description = "The ID of the Amazon Machine Image (AMI) to use for the EC2 instance"
  default = "ami-064087b8d355e9051"
  type        = string
}

variable "security_groups" {
  description = "A list of security group IDs to associate with the EC2 instance"
  type        = list(string)
  default     = []
}

variable "key_name" {
  description = "Key for ssh connection"
  type            = string  
  default  = "doku-1"
}


#######
# EFS #
#######

variable "name_efs" {
  description = "Name for EFS attached to ec2 incatnces"
  type = string
  default = "efs-doku"
}

variable "creation_token_efs" {
  description = "Creation token for EFS"
  type = string
  default = "efs-token"
}

variable "sg_name_efs" {
  description = "Name for EFS security group"
  type = string
  default = "EFS security group"
}

variable "throughput_mode" {
  type = string
  default = "bursting"
}

variable "performance_mode" {
  type = string
  default = "generalPurpose"
}
#######
# ALB #
#######

variable "name_alb" {
  description = "Name for ALB attached to ec2 incatnces"
  type = string
  default = "albForDoku"
}

variable "name_prefix_tg" {
  type = string
  default = "mytg"
}

