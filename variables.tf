variable "aws_partition" {
  type        = string
  description = "The AWS partition to use for the bucket ARNs."
  default     = "aws"
}

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

variable "kubernetes_role_assumption_config" {
  type = object({
    aws_account_id                 = string
    oidc_provider                  = string
    namespace                      = string
    server_service_account_name    = string
    drain_service_account_name     = string
    scheduler_service_account_name = string
  })
  description = "The configuration to use to allow pods running in EKS to assume the roles. By default this is null and ECS role assumption statements will be generated."
  default     = null
}

variable "sqs_queues" {
  type = object({
    deadletter      = string
    deadletter_fifo = string
    async_jobs      = string
    events_inbox    = string
    async_jobs_fifo = string
    cronjobs        = string
    webhooks        = string
    iot             = string
  })
  description = "A map of SQS queue ARNs, in case the user chooses to use SQS for message queues."
  default     = null
}

variable "secrets_manager_secret_arns" {
  type        = list(string)
  description = "List of additional secrets manager secret ARNs to use for the application. These will be added to the execution role policy."
  default     = []
}

variable "iot_topic" {
  type        = string
  description = "The IoT topic when AWS IoT is used as a message broker."
  default     = null
}
