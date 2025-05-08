# 14-Day Terraform Challenge From Beginner to Expert:  Day-2 Resources and Providers


**Estimated Time**: 3.5 hours

## Topics:
- 1. What are Providers in Terraform 
- 2. Understanding Resources , Resource blocks and syntax
- 3. Multiple resource creation
- 4. Resource dependencies
- 5. Resource attributes and references
- 6. Project: "Multi-Resource Deployment



## 1 Understanding Terraform Providers
When you install terraform fresh you cannot use it to do much, a fresh installation of terraform just gives you the terraform core binaries. To interact with cloud providers, SaaS providers, and other APIs terraform uses plugins(extentions). In a nutshell Providers  act as  plugins that enables terraform to manage resources in various platforms like AWS, Azure, GCP, and many others. Without providers, Terraform can't manage any kind of infrastructure.


**Key Points on Providers:**
- Providers are responsible for the  API interactions between terraform and  various platforms(cloud providers, SaaS providers, and other APIs)
- Each provider has its own documentation, describing its resource types and their arguments.
- The Terraform Registry (registry.terraform.io) is the main source for providers
- Providers are released separately from Terraform itself and have their own version numbers.
- Providers need to be declared and configured before use
- Providers are written in Go, using the Terraform Plugin SDK.
- Common providers include AWS, Azure, GCP, GitHub, Kubernetes etc



### Provider Configuration
To uses providers you need to configure them before. Provider configuration specifies the settings that are needed to interact with the target API.
The  various configurations options are listed bellow:  

**Configuration Options:**
- 1.Authentication mechanisms (access keys, tokens, certificates)
- Endpoint URLs
- Default region or location
- Proxy settings and custom headers
- Rate limiting and retry behavior

**Provider Authentication Methods:**
1. Static credentials in configuration (not recommended for production)
2. Environment variables
3. Shared credential files (e.g., ~/.aws/credentials)
4. Instance profiles or service accounts
5. Identity federation

A provider configuration is created using a provider block as shown bellow 

```bash
provider "aws" {
  region = "us-west-2"
}
```
The name in the above provider block "aws" is the local provider name to configure. This provider should already be included in a required_providers block in the terraform configuration block. The body "{}" contains all the configuration options for the provider.

**Example of provider declaration:**
```bash
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
}

provider "aws" {
  region = "us-west-2"
}
```

  




## 2. Understanding Resources , Resource blocks and syntax

Resources are the main building blocks/elements  in Terraform.  Resource block describes one or more infrastructure objects like virtual networks, compute instances, or DNS records. A resource block declares a resource of a specific type with a specific local name. Terraform uses the name when referring to the resource in the same module, but it has no meaning outside that module's scope.

**Resource Block Syntax:**

```bash
resource "provider_type" "resource_name" {
  attribute1 = value1
  attribute2 = value2
  
  nested_block {
    nested_attribute = value
  }
  
}
```
**Key Components of a Resource Block:**
- 1. `provider_type`: The type of resource, determined by the provider (e.g., aws_instance)
- 2. `resource_name`: A user-defined name for the resource, used as an identifier in Terraform
- 3. Attributes: Configuration settings specific to the resource type
- 5. Nested blocks: Structured configuration for complex resource properties


## Multiple Resource Creation

In Terraform configurations,  typically there are  multiple related resources that come together to define a complete infrastructure environment.

**Best Practices:**
- Group related resources into logical modules
- Use consistent naming conventions
- Leverage resource attributes to establish relationships
- Consider resource lifecycle dependencies
- Use variables to make configurations reusable

**Example of multiple related resources:**
```bash
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  
  tags = {
    Name = "main-vpc"
  }
}

resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-west-2a"
  
  tags = {
    Name = "public-subnet"
  }
}

resource "aws_security_group" "web" {
  name        = "web-sg"
  description = "Allow web traffic"
  vpc_id      = aws_vpc.main.id
  
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```

## Resource Dependencies

Terraform manages dependencies between resources to ensure proper creation, update, and deletion order.

**Types of Dependencies:**
1. **Implicit dependencies**: When one resource references attributes of another
2. **Explicit dependencies**: Using the `depends_on` argument to force dependencies
3. **Meta-arguments**: Affecting resource behavior like `count`, `for_each`, and `lifecycle`

**Implicit Dependency Example:**
```hcl
# Database instance implicitly depends on subnet group
resource "aws_db_subnet_group" "example" {
  name       = "example"
  subnet_ids = [aws_subnet.a.id, aws_subnet.b.id]
}

resource "aws_db_instance" "example" {
  subnet_group_name = aws_db_subnet_group.example.name
  # Other configuration...
}
```

**Explicit Dependency Example:**
```hcl
resource "aws_s3_bucket" "example" {
  bucket = "example-bucket"
}

resource "aws_iam_role_policy" "example" {
  name   = "example"
  role   = aws_iam_role.example.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["s3:*"]
        Effect   = "Allow"
        Resource = [aws_s3_bucket.example.arn]
      }
    ]
  })
  
  # Force dependency even if not referenced in attributes
  depends_on = [aws_s3_bucket_policy.example]
}
```

## Resource Attributes and References

Terraform resources expose attributes that can be referenced in other parts of the configuration.

**Attribute Reference Syntax:**
```
<RESOURCE_TYPE>.<NAME>.<ATTRIBUTE>
```

**Common Use Cases:**
- Connecting resources (e.g., associating subnet with VPC)
- Output values for visibility
- Input to data sources or modules
- Dynamic configuration based on provisioned resources

**Example of attribute references:**
```hcl
resource "aws_instance" "web" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public.id
  
  tags = {
    Name = "WebServer"
  }
}

resource "aws_eip" "web" {
  instance = aws_instance.web.id
}

output "web_public_ip" {
  value = aws_eip.web.public_ip
}

resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = "www.example.com"
  type    = "A"
  ttl     = 300
  records = [aws_eip.web.public_ip]
}
```

## Project: "Multi-Resource Deployment"

### 1. Create Configuration with Multiple Related Resources

### 2. Using Resource Attributes to Establish Dependencies

In the configuration above, I've established multiple implicit dependencies through resource attributes:

- The subnets reference the VPC ID via `aws_vpc.main.id`
- The route table references the VPC ID via `aws_vpc.main.id`
- The route references the route table and internet gateway via `aws_route_table.public.id` and `aws_internet_gateway.main.id`
- The route table association links the subnet and route table via references
- Security groups reference the VPC ID
- The EC2 instance references both the subnet and security group
- The EIP association references both the instance and elastic IP allocation

These implicit dependencies ensure that Terraform creates resources in the correct order.

### 3. Implementing Explicit Dependencies with `depends_on`

In the configuration, I've included explicit dependencies with `depends_on` for:

1. The EC2 instance depends on the route table association:
```hcl
depends_on = [aws_route_table_association.public]
```
This ensures the instance isn't created until the subnet is properly routed to the internet.

2. The Elastic IP depends on the Internet Gateway:
```hcl
depends_on = [aws_internet_gateway.main]
```
This ensures the EIP isn't allocated until the Internet Gateway exists.

### 4. Applying and Testing Your Configuration

To apply this configuration:

1. Save the code to a file named `main.tf`
2. Initialize Terraform in the directory:
```bash
terraform init
```

3. Create an execution plan:
```bash
terraform plan
```

4. Apply the configuration:
```bash
terraform apply
```

5. Test the deployment:
   - Verify VPC and subnets in AWS console
   - Check the EC2 instance is running
   - Verify connectivity to the web server using the output IP
   - Test SSH access to the instance
   - Validate security group rules are working

6. When finished, clean up resources:
```bash
terraform destroy
```

This project demonstrates key Terraform concepts:
- Creating multiple interrelated resources
- Using both implicit and explicit dependencies
- Proper resource ordering
- Output values for important resource attributes
- Tagging resources for better organization
- Variable usage for flexibility


# Referrences 
1. https://developer.hashicorp.com/terraform/language/providers
2. https://developer.hashicorp.com/terraform/language/providers/configuration