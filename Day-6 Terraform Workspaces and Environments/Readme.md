# 14-Day Terraform Challenge From Beginner to Expert:  Day-6 Terraform Workspaces and Environments


## Table of Contents
- [Terraform Workspaces ](#Terraform-Workspaces)
- [Module Structure and Organization](#Module-Structure-and-Organization)
- [Local and remote modules](#Local-and-remote-modules)
- [Module inputs and outputs](#Module-inputs-and-outputs)
- [Module versioning](#Module-versioning)
- [ Module composition](#Module-composition)
- [Project  ](#Project)
- [Conclusion](#Conclusion)
- [References](#References)

## Terraform Workspaces
### Introduction 
In our last chapter, Day-5,  we dived deep into modules and how create and use modules. We explored how to use modules in  separate environments  dev, staging, and prod which is  best practice. But how do we manage those environments effectively? Well Terraform has got as covered on that. Terraform  offers various techniques and approaches  to manage multiple environments effectively.Today we will be looking at another important fearure of  terraform, workspaces and environments. We will look at what Terraform workspaces are and  environment management strategies. 


### What are Terraform Workspaces?

A workspace in Terraform enables you to manage multiple state files in seperate and  isolated containers with same Terraform configurations. In a nutshell a workspace in Terraform isolates state. Which means that the same code(configuration) having different state files each workspace storing and managing its own `tfstate`. This is 
ideal for managing dev,test,stage,prod using  the same code base. Some backends(S3,AzureRM,GCS,Kubernetes etc) supports multiple  workspaces, allowing multiple states to be associated with a single configuration.


When you initially create resources in Terraform, the resources are created a the  a single workspace named `"default"` and if you don't specifically define one, Terraform will utilise the `default` workspace the entire time which cannot be delete .To create a new workspace  or switch between workspaces, you use the `terraform workspace`  commands.

### Key Workspace Commands

- **1.Creating a new workspace** 
```bash
terraform workspace new dev
```
- **2.List available workspaces** 
```bash
terraform workspace list
```
- **3.Selecting a workspace** 
```bash
terraform workspace select prod
```
- **4. Show current workspace** 
```bash
terraform workspace show
```

- **5.Delete a workspace** 
```bash
terraform workspace delete dev
```


### Benefits of Workspaces

- **Simplicity**: Easy to implement with minimal configuration changes
- **Built-in functionality**: Native to Terraform without requiring external tools
- **State isolation**: Each workspace maintains its own state file
- **Resource naming**: The workspace name can be interpolated in your configuration

### Limitations of Workspaces

- **State storage**: All state files are stored in the same backend location (just with different keys)
- **Configuration sharing**: All workspaces share the same configuration files
- **Backend configuration**: Backend configuration is shared across workspaces
- **Workspace management**: Can become unwieldy for complex setups with many environments

### When to Use Workspaces

Workspaces are best suited for:

- Small to medium-sized projects
- Environments with identical infrastructure that differ only in sizing or counts
- Testing temporary changes without affecting the primary infrastructure
- Teams with straightforward workflow requirements

## 🧩 2. Environment Management Strategies

### 1. Workspace-based Strategy

### 2. Directory-Based Structure