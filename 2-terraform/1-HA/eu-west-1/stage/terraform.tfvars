project               = "sp_project_staging"
environment           = "staging"
region                = "eu-west-1"
availability_zones    = ["eu-west-1a"]
vpc_cidr              = "10.1.0.0/16"
public_subnets_cidr   = ["10.1.10.0/24"] //List of Public subnet cidr range
private_subnets_cidr  = ["10.1.30.0/24"] //List of private subnet cidr range
