# CONFIGURATION

## Secrets

Use GitHub’s repository settings to securely store sensitive information in this case AWS Credentials

1. Navigate to Settings

2. On the left sidebar, select "Secrets and variables" > "Actions"

## Pipeline

1. Navigate to Actions

2. Either set up a workflow yourself or use a reconfigure workflow

3. Our setup include 2 workflows, one to deploy infrastructure [deployment.yml](.github/workflows/deployment.yml) 

# USAGE

The [terraform.yml](../../.github/workflows/deployment.yml) workflow will trigger automatically

By clicking Run workflow

# VERSION
AWS Provider Version 5.70.0

Terraform Version >= 1.0
