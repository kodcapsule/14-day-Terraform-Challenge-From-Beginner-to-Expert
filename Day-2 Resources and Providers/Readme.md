# 14-Day Terraform Journey/Challenge From Beginner to Expert:  Day-2 Resources and Providers


**Estimated Time**: 3.5 hours

## Topics:
- Understanding Terraform providers
- Resource blocks and syntax
- Provider configuration
- Multiple resource creation
- Resource dependencies
- Resource attributes and references

### Project: "Multi-Resource Deployment"
1. Create a configuration with multiple related resources (e.g., VPC, subnets, and security groups)
2. Use resource attributes to establish dependencies
3. Implement explicit dependencies using `depends_on`
4. Apply and test your configuration

## Understanding Terraform Providers

Providers are Terraform's connection to external APIs and services. They act as plugins that allow Terraform to manage resources in various platforms like AWS, Azure, GCP, and many others.

**Key Points:**
- Providers are responsible for understanding API interactions and exposing resources
- Each provider offers a set of resource types and data sources
- The Terraform Registry (registry.terraform.io) is the main source for providers
- Providers need to be declared and configured before use
- Common providers include AWS, Azure, GCP, GitHub, Kubernetes, and HashiCorp products

**Example of provider declaration:**
```hcl
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

## Resource Blocks and Syntax

Resources are the primary element in Terraform. Each resource block describes one or more infrastructure objects like virtual networks, compute instances, or DNS records.

**Resource Block Syntax:**
```hcl
resource "provider_type" "resource_name" {
  attribute1 = value1
  attribute2 = value2
  
  nested_block {
    nested_attribute = value
  }

  dynamic "dynamic_block" {
    for_each = some_collection
    content {
      attribute = dynamic_block.value
    }
  }
}
```

**Key Components:**
- `provider_type`: The type of resource, determined by the provider (e.g., aws_instance)
- `resource_name`: A user-defined name for the resource, used as an identifier in Terraform
- Attributes: Configuration settings specific to the resource type
- Nested blocks: Structured configuration for complex resource properties
- Dynamic blocks: Generate repeated nested blocks based on collections

## Provider Configuration

Provider configuration specifies the settings needed to interact with the target API.

**Configuration Options:**
- Authentication mechanisms (access keys, tokens, certificates)
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

**Example of AWS provider with authentication:**
```hcl
provider "aws" {
  region     = "us-east-1"
  profile    = "production"
  max_retries = 5
  
  assume_role {
    role_arn = "arn:aws:iam::123456789012:role/TerraformRole"
  }

  default_tags {
    tags = {
      Environment = "Production"
      ManagedBy   = "Terraform"
    }
  }
}
```

## Multiple Resource Creation

Terraform configurations typically include multiple related resources to define complete infrastructure environments.

**Best Practices:**
- Group related resources into logical modules
- Use consistent naming conventions
- Leverage resource attributes to establish relationships
- Consider resource lifecycle dependencies
- Use variables to make configurations reusable

**Example of multiple related resources:**
```hcl
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

```hcl
# Multi-Resource Deployment Configuration

# Configure AWS Provider
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
  required_version = ">= 1.2.0"
}

provider "aws" {
  region = var.aws_region
}

# Define variables
variable "aws_region" {
  description = "AWS region to deploy resources"
  default     = "us-west-2"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  default     = "10.0.0.0/16"
}

variable "environment" {
  description = "Deployment environment"
  default     = "dev"
}

# VPC Resource
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  
  tags = {
    Name        = "${var.environment}-vpc"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# Internet Gateway for VPC
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  
  tags = {
    Name        = "${var.environment}-igw"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# Public Subnet
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, 1)
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true
  
  tags = {
    Name        = "${var.environment}-public-subnet"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# Private Subnet
resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, 2)
  availability_zone = "${var.aws_region}b"
  
  tags = {
    Name        = "${var.environment}-private-subnet"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# Route Table for Public Subnet
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  
  tags = {
    Name        = "${var.environment}-public-rt"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# Route to Internet Gateway
resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

# Route Table Association with Public Subnet
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Security Group for Web Servers
resource "aws_security_group" "web" {
  name        = "${var.environment}-web-sg"
  description = "Security group for web servers"
  vpc_id      = aws_vpc.main.id
  
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTP traffic"
  }
  
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTPS traffic"
  }
  
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow SSH access"
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }
  
  tags = {
    Name        = "${var.environment}-web-sg"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# Security Group for Database
resource "aws_security_group" "db" {
  name        = "${var.environment}-db-sg"
  description = "Security group for database instances"
  vpc_id      = aws_vpc.main.id
  
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.web.id]
    description     = "Allow MySQL traffic from web servers"
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }
  
  tags = {
    Name        = "${var.environment}-db-sg"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# EC2 Instance in Public Subnet
resource "aws_instance" "web" {
  ami                    = "ami-0c55b159cbfafe1f0"  # Amazon Linux 2 AMI (adjust for your region)
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.web.id]
  
  # Example of user data for a web server
  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "<h1>Hello from Terraform</h1>" > /var/www/html/index.html
              EOF
  
  tags = {
    Name        = "${var.environment}-web-server"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
  
  # Explicit dependency - wait for route table association
  depends_on = [aws_route_table_association.public]
}

# Elastic IP for Web Server
resource "aws_eip" "web" {
  vpc = true
  
  tags = {
    Name        = "${var.environment}-web-eip"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
  
  # Explicitly depend on Internet Gateway
  depends_on = [aws_internet_gateway.main]
}

# EIP Association
resource "aws_eip_association" "web" {
  instance_id   = aws_instance.web.id
  allocation_id = aws_eip.web.id
}

# Outputs
output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_id" {
  description = "ID of the public subnet"
  value       = aws_subnet.public.id
}

output "private_subnet_id" {
  description = "ID of the private subnet"
  value       = aws_subnet.private.id
}

output "web_server_public_ip" {
  description = "Public IP address of the web server"
  value       = aws_eip.web.public_ip
}
```

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
