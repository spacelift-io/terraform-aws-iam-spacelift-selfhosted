variable "kms_encryption_key_arn" {
  type        = string
  description = "The ARN of the KMS key ID to use for in-app encryption."
}

variable "kms_signing_key_arn" {
  type        = string
  description = "The ARN of the KMS key used to sign JWTs."
}

variable "kms_key_arn" {
  type        = string
  description = "The ARN of the KMS key to use for encrypting AWS resources (S3, ECR etc.)."
}

variable "deliveries_bucket_name" {
  type        = string
  description = "The name of the deliveries bucket."
}

variable "large_queue_messages_bucket_name" {
  type        = string
  description = "The name of the large queue messages bucket."
}

variable "metadata_bucket_name" {
  type        = string
  description = "The name of the metadata bucket."
}

variable "modules_bucket_name" {
  type        = string
  description = "The name of the modules bucket."
}

variable "policy_inputs_bucket_name" {
  type        = string
  description = "The name of the policy inputs bucket."
}

variable "run_logs_bucket_name" {
  type        = string
  description = "The name of the run logs bucket."
}

variable "states_bucket_name" {
  type        = string
  description = "The name of the states bucket."
}

variable "uploads_bucket_name" {
  type        = string
  description = "The name of the uploads bucket."
}

variable "user_uploaded_workspaces_bucket_name" {
  type        = string
  description = "The name of the user uploaded workspaces bucket."
}

variable "workspace_bucket_name" {
  type        = string
  description = "The name of the workspace bucket."
}

variable "write_as_files" {
  type        = bool
  description = "Whether to write the policies as files to disk"
  default     = false
}

variable "aws_partition" {
  type        = string
  description = "The AWS partition to use for the bucket ARNs."
  default     = "aws"
}