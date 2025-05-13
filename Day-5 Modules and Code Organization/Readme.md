# 14-Day Terraform Challenge From Beginner to Expert:  Day-5 Terraform Modules and Code Organization


## Table of Contents
- [Understanding  Modules in Terraform ](#Understanding-Modules-in-Terraform)
- [Module Structure and Organization](#Module-Structure-and-Organization)
- [Local and remote modules](#Local-and-remote-modules)
- [Module inputs and outputs](#Module-inputs-and-outputs)
- [Module versioning](#Module-versioning)
- [ Module composition](#Module-composition)
- [Project  ](#Project)
- [Conclusion](#Conclusion)
- [References](#References)


## Understanding Modules in Terraform
### Introduction
In day 4 we deploy a fully functional  infrastructure which consist of so many components. This is great , but what if your manager comes to you and say that you need to deploy this same infrastructure in different environments, dev, staging and prod, what will you do? Ideally, these  environments are nearly identical, though the staging and dev  might run slightly  fewer/smaller infrastructure   to save money. Well  you may be tempted to  copy and  paste all of the code from dev to staging and prod but this defeats the concept of `Don't Repeat Yourself` (DRY) principle. This is where terraform modules comes to the rescue. 

Modules are essential for developing  reusable, maintainable, and testable Terraform code.Once you start using modules, there is no turning back. In Day 5 we will take a look at Terraform modules in detail and how to create and use Terraform modules. 

### What are Terraform Modules?
HashiCorp defines modules as a container for multiple resources that are used together.In simple terms , a Terraform module is a list of terraform configuration files in a single diretory/folder.A module consists of a collection of .tf and/or .tf.json files kept together in a directory.

A  Terraform module is analogous to a function in general-purpose programming contracts, they have parameters(input variables) and return values (output values). A module can be as simple as a directory with one or more configuration files.tf files. For example you can define a reusable VPC module which might include subnets, route tables and security groups. 

### Types of Modules
- **1.Root Module:** Every Terraform configuration must have at a minimum of  one module, known as the root module, which contains the resources defined in the `.tf` files in the main working directory.
- **2.Child Modules:**A module called by another module is commonly referred to as a child module.  Child modules can be called more than once in the same configuration, and the same child module can be used in numerous configurations.



## Standard Module Structure

A well-structured Terraform module typically follows a standard directory layout:

```bash
my-module/
│
├── main.tf        # Primary resource definitions
├── variables.tf   # Input variable declarations
├── outputs.tf     # Output value definitions
├── versions.tf    # Provider and Terraform version constraints
├── README.md      # Module documentation
└── examples/      # Example use cases and implementations
```

Key components of this structure include:

1. **main.tf**: Contains the primary resource definitions and core logic of the module
2. **variables.tf**: Defines input variables that can be customized when using the module
3. **outputs.tf**: Specifies output values that can be used by other modules or configurations
4. **versions.tf**: Sets constraints for Terraform and provider versions
5. **README.md**: Provides documentation on module usage, inputs, and outputs


### Syntax for using a Module

```bash
module "<NAME>" {
  source = "<SOURCE>" 
[CONFIG ...]
 }
```
- 1.NAME: This is an identifier/label that  you can use throughout the Terraform code to  refer to this module 
- 2.SOURCE: The source argument tells Terraform where to find the source code for the desired child module.
- 3.CONFIG:  consists of arguments that are specific to that  module. 


## Local and remote modules
Terraform supports two primary types of modules:

### Local Modules
Local modules exist within your file system, typically in subdirectories of your main Terraform configuration.

Local modules are stored in the same directory structure as your main Terraform configuration. They are ideal for:
- Project-specific infrastructure components
- Organizing complex configurations
- Sharing code within a single project or organization

Example of using a local module:
```bash
module "network" {
  source = "./modules/network"
  region = var.region
  vpc_cidr = "10.0.0.0/16"
}
```

### Remote Modules
Remote modules are stored in external repositories, allowing for broader sharing and reuse:
- Public module registries (Terraform Registry)
- Private module registries
- Version control systems like GitHub

Example of using a remote module:
```bash
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.14.0"
  
  name = "my-vpc"
  cidr = "10.0.0.0/16"
}
```



## Module inputs and outputs
## Module versioning
## Module composition
## Project
## Conclusion
## References