variable "aws_region" {
  type        = string
  description = "The AWS region in which resources will be administered"
}

variable "aws_account" {
  type        = string
  description = "The name of the AWS Account in which resources will be administered"
}

variable "application" {
  type        = string
  description = "The name of the application"
}

variable "fe_domain_name" {
  type        = string
  description = "Domain name of the ACM certificate used for the external ALB"
  default     = "*.companieshouse.gov.uk"
}

variable "fe_public_access_cidrs" {
  type        = list(string)
  description = "List of CIDR blocks requiring public access"
  default     = []
}
