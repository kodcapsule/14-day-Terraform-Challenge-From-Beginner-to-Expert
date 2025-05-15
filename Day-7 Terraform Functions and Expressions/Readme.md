# 14-Day Terraform Challenge From Beginner to Expert:  Day-7 Terraform Functions and Expressions

## Table of Contents
- [Introduction](#Introduction)
- [HCL Expressions Fundamentals](#HCL-Expressions-Fundamentals)
- [Built-in Functions](#Built-in-Functions)
- [Conditional Expressions](#Conditional-Expressions)
- [For Expressions](#For-Expressions)
- [Dynamic Blocks](#Dynamic-Blocks)
- [String Manipulation](#String-Manipulation)
- [Project](#Project)
- [Conclusion](#Conclusion)
- [References](#References)


## Introduction
- What are Terraform Functions and Expressions
- Why They Matter for Infrastructure as Code

Terraform is a powerful IaC tool because of its declarative nature, but in declarative languages, certain types of tasks, like repeating a piece of logic(for-loops) or conditional logic (if-statements), are usually required. How can you conditionally configure resources, for example, by building a Terraform module that can provide specific resources for some users but not for others, if declarative languages do not support if-statements?

The good news is that Terraform has several primitives that let you perform specific kinds of loops, if-statements, and other operations, including the meta parameter count, for_each and for expressions, a ternary operator, a lifecycle block called create_before_destroy, and other built-in functions.

 On day 7 we will explore HCL expressions, built-in functions, conditional expressions, for expressions, dynamic blocks, and string manipulation techniques in Terraform. Grab a cup of coffee; let's get started.


## HCL Expressions Fundamentals
HashiCorp Configuration Language (HCL), expressions gives you the ability to refer to or compute values in a terraform configuration. The simplest expressions in terraform are   `"kodecapsule"`, `5.7`, that is literal values. You may experiment with the behaviour of Terraform's expressions using the Terraform expression console by using the terraform console command.

### Types of Expressions

1. **Literal Expressions**: directly represents a particular constant value in a terraform configuartion. These are usually  the basic values such as  strings, numbers, booleans, etc.
 Example 
   ```bash
   resource "aws_instance" "example" {
     instance_type = "t2.micro"  # String literal
     count         = 3           # Number literal
     monitoring    = true        # Boolean literal
   }
   ```

2. **References**: Access attributes from resources, variables, data sources, etc.
   ```bash
   resource "aws_instance" "web" {
     ami           = data.aws_ami.ubuntu.id  # Reference to data source
     instance_type = var.instance_type       # Reference to variable
   }
   ```

3. **Operators**: Perform operations on values.
   ```bash
   locals {
     total_instances = var.environment == "prod" ? 6 : 2  # Conditional operator
     subnet_count    = length(var.subnet_ids)             # Function call
   }
   ```

4. **Function Calls**: Invoke built-in or custom functions to transform values.
   ```bash
   locals {
     upper_name = upper(var.name)
     timestamp  = formatdate("YYYY-MM-DD", timestamp())
   }
   ```

## Built-in Functions
Terraform , like AWS CloudFormation, includes many built-in functions that can be used to do common operations within expressions, such as transforming and combining values. The basic syntax for function calls is a function name followed by comma-separated arguments in brackets. 
 <SYNTAX> '\FUNCTION NAME> (<ARGUMENTS>)'

 Example:
 ```bash 
   max(5, 12, 9)
  ```
 Terraform functions are similar to AWS CloudFormation intrinsic functions, but their syntax is more like  how functions are invoked in general programming languages. 
 Terraform functions can be categorised according to their purpose.

### Numeric Functions

```bash
locals {
  # Calculate optimal instance count based on load
  instance_count = max(2, min(10, ceil(var.expected_users / 50)))
  
  # Calculate storage in GB with 20% buffer
  storage_size = ceil(var.required_storage * 1.2)
}
```

### String Functions

```bash
locals {
  # Format resource names consistently
  resource_name = lower(format("%s-%s-%s", var.project, var.environment, var.component))
  
  # Split comma-separated tags into a list
  tags_list = split(",", var.tags_string)
  
  # Join list elements into a comma-separated string
  tags_display = join(", ", var.tags_list)
}
```

### Collection Functions

```bash
locals {
  # Filter production environments
  prod_environments = [for env in var.environments : env if env.is_production]
  
  # Create a map of instance types by environment
  instance_types = {
    for env_name, env_config in var.environments : 
    env_name => lookup(env_config, "instance_type", "t3.micro")
  }
}
```

### IP Network Functions

```bash
locals {
  # Calculate CIDR blocks for subnets
  subnet_cidrs = [
    cidrsubnet(var.vpc_cidr, 8, 0),
    cidrsubnet(var.vpc_cidr, 8, 1),
    cidrsubnet(var.vpc_cidr, 8, 2)
  ]
  
  # Check if IP is in network range
  internal_access = cidrcontains(var.vpc_cidr, var.access_ip)
}
```

### Encoding Functions

```bash
locals {
  # Base64 encode user data for EC2 instances
  user_data = base64encode(templatefile("${path.module}/user_data.tpl", {
    environment = var.environment
    db_endpoint = aws_db_instance.main.endpoint
  }))
}
```




## Conditional Expressions
- Ternary Operator
- Conditional Resource Creation


## Conditional Expressions

Conditional expressions enable you to make resource creation and configuration decisions based on conditions:

### Ternary Operator

```bash
locals {
  # Choose instance type based on environment
  instance_type = var.environment == "prod" ? "m5.large" : "t3.micro"
  
  # Set backup retention based on environment criticality
  backup_retention = var.is_critical ? 30 : var.environment == "prod" ? 14 : 7
}
```

### Conditional Resource Creation

```bash
# Only create this resource in production
resource "aws_elasticache_cluster" "redis" {
  count = var.environment == "prod" ? 1 : 0
  
  cluster_id           = "cache-${var.environment}"
  engine               = "redis"
  node_type            = "cache.t3.micro"
  num_cache_nodes      = 1
  parameter_group_name = "default.redis6.x"
}
```


## References
https://docs.aws.amazon.com/prescriptive-guidance/latest/getting-started-terraform/functions-expressions.html
https://developer.hashicorp.com/terraform/language/expressions/types
https://developer.hashicorp.com/terraform/language/expressions
https://developer.hashicorp.com/terraform/language/functions
