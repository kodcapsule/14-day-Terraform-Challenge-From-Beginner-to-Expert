# ## Project: "Hello, Infrastructure!"

# For this project, you'll create a simple Terraform configuration that provisions a basic AWS cloud resource, S3 bucket. 
# This project will help you understand the core concepts of Terraform, including providers, resources, variables, and outputs.
# You'll also learn how to initialize Terraform, create a plan, and apply the configuration to provision the resource.:



# **Example S3 Bucket Configuration**:/
# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

# Create an S3 bucket
resource "aws_s3_bucket" "my_first_bucket" {
  bucket = "my-first-terraform-bucket-kodecapsule"
  
  tags = {
    Name        = "My First Terraform Bucket"
    Environment = "Development"
    Project     = "Terraform Learning"
    Day         = "1"
  }
}

# Output the bucket name
output "bucket_name" {
  value       = aws_s3_bucket.my_first_bucket.bucket
  description = "The name of the S3 bucket"
}

# Output the bucket ARN
output "bucket_arn" {
  value       = aws_s3_bucket.my_first_bucket.arn
  description = "The ARN of the S3 bucket"
}


