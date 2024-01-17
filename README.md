# wck-terraform

> [!ALERT]
> This service has been deprecated. A minimal set of infrastructure is being maintained in the `ch-heritage-live` account to support a customer-facing service discontinuation page for a period of time before this repository will be archived.

## What is this repo?
This repo contains the required infrastructure for the WCK Application stack
This will be deployed to Dev, Staging and Live so the Terraform code is generic with var files per account in the profiles sub-directory (per group).

## The Groups of Terraform

### groups/wck-infrastructure
Contains any existing resources created in AWS for the CHD Application, additional resources can be added as and when required.
