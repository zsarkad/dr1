Created VPC for each environment  - prod and stage
Prod environment has multiple az for reliability and availability and stage environment only have one az. Created common vpc module and defined variables for each environment. This project also can be deployed to multiple region while duplicate the root folder. (If It's enough to have one staging env so you can remove it for other regions)

└── eu-west-1
    ├── modules
    │   └── networking
    │       ├── main.tf
    │       └── variables.tf
    ├── prod
    │   ├── main.tf
    │   ├── prod.tfvars
    │   ├── terraform.tfvars
    │   └── variables.tf
    └── stage
        ├── main.tf
        ├── prod.tfvars
        ├── terraform.tfvars
        └── variables.tf
   
