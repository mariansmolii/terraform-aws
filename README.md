## Terraform AWS Infrastructure with Custom Modules

This repository contains Terraform code to provision infrastructure on AWS. The infrastructure is defined using a set of custom, reusable Terraform modules.

## Folder Structure

```plaintext
modules
├── autoscaling
├── ec2
├── lb
├── security_group
├── ssh_key
└── vpc
```

## Usage

- **Clone the Repository**

```bash
  https://github.com/mariansmolii/terraform-aws.git
  cd terraform-aws
```

- **Initialize Terraform**

```bash
  terraform init
```

- **Plan Infrastructure**

```bash
  terraform plan
```

- **Apply the Configuration**

```bash
  terraform apply
```

- **Destroy the Infrastructure**

```bash
  terraform destroy
```
