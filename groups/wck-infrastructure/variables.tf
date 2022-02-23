# ------------------------------------------------------------------------------
# AWS Variables
# ------------------------------------------------------------------------------
variable "aws_region" {
  type        = string
  description = "The AWS region in which resources will be administered"
}

variable "aws_profile" {
  type        = string
  description = "The AWS profile to use"
}

variable "aws_account" {
  type        = string
  description = "The name of the AWS Account in which resources will be administered"
}

# ------------------------------------------------------------------------------
# AWS Variables - Shorthand
# ------------------------------------------------------------------------------

variable "account" {
  type        = string
  description = "Short version of the name of the AWS Account in which resources will be administered"
}

variable "region" {
  type        = string
  description = "Short version of the name of the AWS region in which resources will be administered"
}

variable "environment" {
  type        = string
  description = "The name of the environment"
}


# ------------------------------------------------------------------------------
# WCK Common Variables
# ------------------------------------------------------------------------------
variable "application" {
  type        = string
  description = "The name of the application"
}

variable "nfs_server" {
  type        = string
  description = "The name or IP of the environment specific NFS server"
  default     = null
}

variable "nfs_mount_destination_parent_dir" {
  type        = string
  description = "The parent folder that all NFS shares should be mounted inside on the EC2 instance"
  default     = "/mnt"
}

variable "nfs_mounts" {
  type        = map(any)
  description = "A map of objects which contains mount details for each mount path required."
  default = {
    SH_NFSTest = {                  # The name of the NFS Share from the NFS Server
      local_mount_point = "folder", # The name of the local folder to mount to if the share name is not wanted
      mount_options = [             # Traditional mount options as documented for any NFS Share mounts
        "rw",
        "wsize=8192"
      ]
    }
  }
}

# ------------------------------------------------------------------------------
# WCK BEP Variables
# ------------------------------------------------------------------------------
variable "bep_ami_name" {
  type        = string
  default     = "wck-*"
  description = "Name of the AMI to use in the BEP Auto Scaling configuration"
}

variable "bep_app_release_version" {
  type        = string
  description = "Version of the application to download for deployment to backend server(s)"
}

variable "bep_asg_desired_capacity" {
  type        = number
  description = "The desired capacity of the BEP ASG"
}

variable "bep_asg_max_size" {
  type        = number
  description = "The max size of the BEP ASG"
}

variable "bep_asg_min_size" {
  type        = number
  description = "The min size of the BEP ASG"
}

variable "bep_asg_schedule_start" {
  type        = bool
  description = "Schedule an auto-start on the BEP ASG"
  default     = false
}

variable "bep_asg_schedule_stop" {
  type        = bool
  description = "Schedule an auto-stop on the BEP ASG"
  default     = false
}

variable "bep_default_log_group_retention_in_days" {
  type        = number
  default     = 14
  description = "Total days to retain logs in CloudWatch log group if not specified for specific logs"
}

variable "bep_instance_size" {
  type        = string
  description = "The size of the ec2 instances to build"
}

variable "bep_cw_logs" {
  type        = map(any)
  description = "Map of log file information; used to create log groups, IAM permissions and passed to the application to configure remote logging"
  default     = {}
}

# ------------------------------------------------------------------------------
# WCK FE Variables
# ------------------------------------------------------------------------------
variable "fe_ami_name" {
  type        = string
  default     = "wck-*"
  description = "Name of the AMI to use in the Frontend Auto Scaling configuration"
}

variable "fe_domain_name" {
  type        = string
  description = "Domain name of the ACM certificate used for the external ALB"
  default     = "*.companieshouse.gov.uk"
}

variable "fe_service_port" {
  type        = number
  default     = 80
  description = "Target group backend port"
}

variable "fe_health_check_path" {
  type        = string
  default     = "/"
  description = "Target group health check path"
}

variable "fe_app_release_version" {
  type        = string
  description = "Version of the application to download for deployment to frontend server(s)"
}

variable "fe_asg_desired_capacity" {
  type        = number
  description = "The desired capacity of the FE ASG"
}

variable "fe_asg_max_size" {
  type        = number
  description = "The max size of the FE ASG"
}

variable "fe_asg_min_size" {
  type        = number
  description = "The min size of the FE ASG"
}

variable "fe_asg_schedule_stop" {
  type        = bool
  description = "Schedule an auto-stop on the FE ASG"
  default     = false
}

variable "fe_asg_schedule_start" {
  type        = bool
  description = "Schedule an auto-start on the FE ASG"
  default     = false
}

variable "fe_cw_logs" {
  type        = map(any)
  description = "Map of log file information; used to create log groups, IAM permissions and passed to the application to configure remote logging"
  default     = {}
}

variable "fe_default_log_group_retention_in_days" {
  type        = number
  default     = 14
  description = "Total days to retain logs in CloudWatch log group if not specified for specific logs"
}

variable "fe_instance_size" {
  type        = string
  description = "EC2 instance size required for FE instances"
}

variable "fe_public_access_cidrs" {
  type        = list(string)
  description = "List of CIDR blocks requiring public access"
  default     = []
}

variable "fe_access_cidrs" {
  type        = list(any)
  description = "List of additional CIDRs requiring access via the internal ALB"
  default     = []
}
