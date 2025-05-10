# 14-Day Terraform Challenge From Beginner to Expert:  Day-3 Variables and Outputs

## Table of Contents
- [Input variables ](#input-variables)
- [Variable definition files](#Variable-definition-files)
- [Local variables](#Local-variables)
- [Output values](#Output-Values)
- [Advanced Variable Techniques](#Advanced-Variable-Techniques)
- [Best Practices for Variable Management](#Best-Practices-for-Variable-Management)
- [Project: Parameterize Day 2 Infrastructure ](#Project:-Parameterize-Day-2-Infrastructure )
- [Conclusion](#Conclusion)
- [References](#References)



## Input Variables 
In traditional programming languages like **Python** and  **Java**,   variables are uesd for **Data storage** and  **Parameter passing**. The purpose of variables in traditional programming languages is  similar to that  in Terraform. In terraform variables are used mainly for **parameterization** making  your terraform modules  more flexible and reusable across different environments (dev, staging, production). Variables essentially make your Terraform configurations more dynamic, maintainable, and overall keeps your terraform modules **DRY** adaptable to changing requirements.


### Declaring an Input Variable
Each input variable accepted by a module must be declared using a variable block. Bellow is the  syntax for  declaring a variable:

```bash
    variable "NAME" { 
    [CONFIG ...]
    }
```
**- 1. NAME:** The `NAME` label after the variable keyword represents the variable's name, which must be unique among all variables in the same module. This name is used to assign a value to the variable from the outside the module  and to refer to the variable's value from within the module. The variable name must be  valid identifier except not  any of Terraforms keywords(source, version, providers etc) 
**- 2. CONFIG:** The body {} of the variable declaration can contain the configuarions of the variable which consist of the following A
 `Arguments`
   - default: A default value which then makes the variable optional.
   -  type: This argument specifies what value types are accepted for the variable.
   -  description: This specifies the input variable's documentation.
   -  validation: A block to define validation rules, usually in addition to type constraints.
   -  ephemeral: This variable is available during runtime, but not written to state or plan files.
   -  sensitive: Limits Terraform UI output when the variable is used in configuration.
   -  nullable: Specify if the variable can be null within the module.



### Variable Types

#### Primitive Variable Types

Terraform supports several primitive types for variables:

- **String**: Text values enclosed in quotes eg `"kodecapsule"`
- **Number**: Numeric values without quotes eg `42`, `3.14`
- **Boolean**: True/false values eg `true`, `false`


#### Complex Types
For more complex  terraform configurations, Terraform offers  defining structured variables:

- **List**: Ordered sequence of values eg `["us-west-1", "us-east-1"]`
- **Map**: Collection of key-value pairs eg `{ name = "instance", size = "t2.micro" }`
- **Set**: Unordered collection of unique values
- **Tuple**: Similar to lists but can contain different types
- **Object**: Complex structure with defined attribute types 

exmaple of object type 
```bash
variable "instance_config" {
  type = object({
    ami           = string
    instance_type = string
    tags          = map(string)
    ebs_volumes   = list(object({
      size        = number
      type        = string
      encrypted   = bool
    }))
  })
}
```
**Note**  null: is one special value that has no type, a value that represents absence or omission.

#### Type Constraints an Custom Validation Rules
To verify user-supplied values for its input variables and resource arguments, Terraform module authors and provider developers can employ comprehensive type constraints.  You can create a more robust user interface for your modules and resources by doing this, but it does take some extra understanding of Terraform's type system.

```bash
variable "environment" {
  type        = string
  description = "Deployment environment"
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be 'dev', 'staging', or 'prod'."
  }
}
```

Multiple validation blocks can be used for more sophisticated rules:

```bash
variable "cidr_block" {
  type        = string
  description = "VPC CIDR block"
  
  validation {
    condition     = can(cidrnetmask(var.cidr_block))
    error_message = "The cidr_block value must be a valid CIDR notation."
  }
  
  validation {
    condition     = cidrnetmask(var.cidr_block) == "255.255.0.0"
    error_message = "The CIDR block must be a /16 network."
  }
}
```

 **Validation Functions**

Terraform provides several functions that are particularly useful for validation:

- `can()`: Tests if an expression can be evaluated without error
- `regex()`: Tests if a string matches a regular expression
- `length()`: Returns the length of a string, list, or map
- `contains()`: Checks if a list contains a given value
- `alltrue()`: Checks if all elements in a list are true
## Variable Definition Files

When you have a lot of variables  across different environments(dev, staging, prod etc) , managing these numerious variables becomes complex and difficult to maintain. Terrform provides a way to manage variables by using variable definition files. Variable definition files uses the same  Terraform language syntax , but  only consist of variable names and  assignments. Terrafrom varible definition  files  names must end with  either `.tfvars` or `.tfvars.json` extentions. Terraform  automatically loads a number of variable definitions files if they are present:

- 1. Files named exactly `terraform.tfvars` or `terraform.tfvars.json`.
- 2. Any files with names ending in `.auto.tfvars` or `.auto.tfvars.json` .


### terraform.tfvars

The standard file for defining variable values is `terraform.tfvars`:

```bash
region         = "us-west-2"
instance_count = 3
enable_monitoring = true
tags = {
  Environment = "Production"
  Department  = "Engineering"
}
```

### Environment-Specific Variable Files

For multi-environment deployments, you can create separate variable files:

- `dev.tfvars`
- `staging.tfvars`
- `production.tfvars`

These can be applied using the `-var-file` flag:

```bash
terraform apply -var-file="production.tfvars"
```

### Variable Precedence

When multiple varibles are provided, Terraform follows a specific precedence. Unerstanding variable precedence is key to managing  complex configurations and troubleshoot unexpected terraform behavior. Variable precedence is outline below from the highest precedence (Environment variables )  to the lowest precedence (Default values). 

1. Environment variables (`TF_VAR_name`)
2. Command line flags (`-var` or `-var-file`)
3. `.auto.tfvars` files (alphabetical order)
4. `terraform.tfvars`
5. Default values in variable declarations

## Local Variables
Local values are like a function's temporary local variables. A local value can only be accessed in expressions within the module where it was declared. Unlike input variables, locals are not exposed outside the module and are used to simplify complex expressions or avoid repetition. 

### Basic Local Variable Usage

```bash
locals {
  common_tags = {
    Project     = "Terraform Demo"
    ManagedBy   = "DevOps Team"
    Environment = var.environment
  }
    # Computed local based on other variables
  instance_name = "${var.project_name}-${var.environment}-instance"
    # Conditional local
  create_public_ip = var.environment == "dev" ? true : false
}
```
Local values are created by a `locals` block (plural), but you reference them as attributes on an object named `local` (singular).


### Common Use cases  for Locals

1. **Tag normalization**: Standardizing resource tags across all deployments
2. **Conditional logic**: Simplifying complex conditional expressions
3. **Data transformations**: Formatting or combining input values
4. **Computed values**: Deriving new values from inputs

```bash
locals {
  # Transform a list into a map
  instance_map = { for i, type in var.instance_types : "instance-${i}" => type }
  
  # Conditionally include optional configurations
  monitoring_config = var.enable_monitoring ? {
    detailed  = true
    interval  = 60
    retention = 14
  } : null
}
```
## Output Values

Output values provide information about your infrastructure on the command line and can expose data for other Terraform configurations to use. Output values are equivalent to return values in traditional programming  languages. Outputs enable modules to share information

 Outputs serve  several important purposes:
- Providing information to the user about created resources
- Sharing data between modules
- Integration with other tools via output formats like JSON


### Declaring  Output Values

SYNTAX
```bash
output "<NAME>" {
  value = <VALUE> 
[CONFIG ...]
 }
```
**- 1. <NAME>:**The name of the output variable, the name can be any identifiable characted but not Terraforms' keywords
**- 2. <VALUE>:**
**- 3. <CONFIG>:** The body of the output block configuaration has optional arguments including: description sensitive, ephemeral, and depends_on. 

### Basic Output Definition

```bash
output "instance_ip" {
  value       = aws_instance.example.public_ip
  description = "The public IP address of the web server"
}

output "load_balancer_dns" {
  value       = aws_lb.example.dns_name
  description = "The DNS name of the load balancer"
  depends_on  = [aws_route53_record.www]
}
```

### Complex Output Structures

Outputs can return complex data types, making them powerful for module composition:

```bash
output "cluster_info" {
  value = {
    endpoint    = aws_eks_cluster.example.endpoint
    kubeconfig  = local.kubeconfig
    node_groups = aws_eks_node_group.example[*].resources
    auth_config = {
      roles     = local.auth_roles
      users     = local.auth_users
    }
  }
  description = "EKS cluster configuration details"
}
```

### Output for Module Composition

When creating reusable modules, outputs enable modules to share information:

```bash
# In the VPC module
output "subnet_ids" {
  value = aws_subnet.private[*].id
}

# In the parent module
module "vpc" {
  source = "./modules/vpc"
  # ...
}

module "database" {
  source     = "./modules/rds"
  subnet_ids = module.vpc.subnet_ids
  # ...
}
```

### Sensitive Outputs

Security is paramount in infrastructure code. Terraform provides mechanisms to protect sensitive information through the `sensitive` attribute for both variables and outputs.

#### Defining Sensitive Outputs

```bash
output "database_password" {
  value       = aws_db_instance.example.password
  description = "The database password"
  sensitive   = true
}
```

#### Behavior of Sensitive Outputs

When an output is marked as sensitive:

1. The value is redacted from regular Terraform output
2. The value is still stored in the state file
3. The value can still be accessed by other modules
4. The value will be masked in logs and terminal output

#### Security Considerations

While the `sensitive` flag helps prevent accidental exposure, it's important to understand its limitations:

- Values are still stored in the state file (potentially unencrypted)
- Anyone with access to the state file can view sensitive values
- For truly sensitive information, consider:
  - Using external secret management systems like HashiCorp Vault
  - Enabling state encryption
  - Implementing strict access controls for state files

```bash
terraform {
  backend "s3" {
    bucket         = "terraform-state-bucket"
    key            = "project/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    kms_key_id     = "arn:aws:kms:us-east-1:123456789012:key/abcd1234-ab12-cd34-ef56-1234567890ab"
    dynamodb_table = "terraform-locks"
  }
}
```




## Advanced Variable Techniques

Beyond the basics, several advanced techniques can make Terraform configurations more powerful and maintainable.

### Dynamic Blocks with Variables

Variables can drive the creation of dynamic blocks, allowing for flexible resource configurations:

```hcl
resource "aws_security_group" "example" {
  name        = "example"
  description = "Example security group"
  
  dynamic "ingress" {
    for_each = var.security_group_rules
    content {
      from_port   = ingress.value.port
      to_port     = ingress.value.port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }
}
```

### Variable Defaults with Locals

Combining locals with variables allows for sophisticated default values:

```hcl
variable "config" {
  type    = map(any)
  default = {}
}

locals {
  default_config = {
    instance_type = "t2.micro"
    disk_size     = 20
    environment   = "dev"
  }
  
  # Merge provided config with defaults, with provided values taking precedence
  final_config = merge(local.default_config, var.config)
}
```

### Conditional Resource Creation

Variables can control whether resources are created:

```hcl
variable "create_database" {
  type    = bool
  default = true
}

resource "aws_db_instance" "example" {
  count = var.create_database ? 1 : 0
  
  # Instance configuration...
}
```
## Best Practices for Variable Management

After exploring the technical aspects of Terraform variables and outputs, let's conclude with best practices for effectively managing them in real-world projects.

### Documentation

Always include thorough documentation for variables:

```hcl
variable "vpc_cidr" {
  type        = string
  description = "The CIDR block for the VPC. Must be a /16 network."
  default     = "10.0.0.0/16"
}
```

### Organize Variables Logically

In larger projects, organize variables by purpose or resource type:

```
variables/
  ├── network.tf      # Network-related variables
  ├── compute.tf      # Compute-related variables
  ├── database.tf     # Database-related variables
  └── common.tf       # Shared variables
```

### Leverage Default Values Strategically

Provide sensible defaults when appropriate:

```hcl
variable "enable_monitoring" {
  type        = bool
  description = "Enable detailed monitoring for instances"
  default     = false
}
```

### Version Your Variable Structures

When making breaking changes to variable structures in shared modules, consider versioning:

```
modules/
  ├── vpc/
  │   ├── v1/
  │   └── v2/
  └── database/
      ├── v1/
      └── v2/
```

### Security Considerations

- Never hardcode sensitive values in your configuration
- Use environment-specific variable files
- Consider external secret management for credentials
- Set appropriate defaults that prioritize security

### Testing Variable Configurations

Implement automated testing for Terraform configurations:

- Unit tests for variable validation
- Integration tests with different variable combinations
- End-to-end tests for complete environments
## Project: Parameterize Day 2 Infrastructure 
 1. Refactor the  day 2 project to use input variables
 2. Create a variables.tf file with descriptions and types
 3. Implement variable validation for critical inputs
 4. Define outputs for important resource attributes
 5. Create multiple .tfvars files for different environments
## Conclusion


Effective management of variables and outputs is fundamental to creating maintainable, secure, and reusable Terraform configurations. By understanding the various types of variables, leveraging validation, and following best practices, you can build infrastructure code that is both flexible and reliable.

Whether you're building simple deployments or complex multi-environment infrastructure, mastering Terraform's variable system will help you create more robust and adaptable Infrastructure as Code solutions. As your infrastructure grows in complexity, these practices will become increasingly important for maintaining manageability and ensuring consistent deployment across environments.
## References
1. https://developer.hashicorp.com/terraform/language/values/variables
2. https://developer.hashicorp.com/terraform/language/expressions/types
3. https://developer.hashicorp.com/terraform/language/values/locals
4. https://developer.hashicorp.com/terraform/language/values/outputs
5. https://spacelift.io/blog/terraform-locals











