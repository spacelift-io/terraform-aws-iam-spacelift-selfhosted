locals {
  deliveries_bucket_arn               = "arn:${var.aws_partition}:s3:::${var.deliveries_bucket_name}"
  large_queue_messages_bucket_arn     = "arn:${var.aws_partition}:s3:::${var.large_queue_messages_bucket_name}"
  metadata_bucket_arn                 = "arn:${var.aws_partition}:s3:::${var.metadata_bucket_name}"
  modules_bucket_arn                  = "arn:${var.aws_partition}:s3:::${var.modules_bucket_name}"
  policy_inputs_bucket_arn            = "arn:${var.aws_partition}:s3:::${var.policy_inputs_bucket_name}"
  run_logs_bucket_arn                 = "arn:${var.aws_partition}:s3:::${var.run_logs_bucket_name}"
  states_bucket_arn                   = "arn:${var.aws_partition}:s3:::${var.states_bucket_name}"
  uploads_bucket_arn                  = "arn:${var.aws_partition}:s3:::${var.uploads_bucket_name}"
  user_uploaded_workspaces_bucket_arn = "arn:${var.aws_partition}:s3:::${var.user_uploaded_workspaces_bucket_name}"
  workspace_bucket_arn                = "arn:${var.aws_partition}:s3:::${var.workspace_bucket_name}"

  ecs_role_assumption_statement = {
    Effect = "Allow"
    Action = "sts:AssumeRole"
    Principal = {
      Service = "ecs-tasks.${var.aws_dns_suffix}"
    }
  }

  ecs_role_assumption_enabled        = var.kubernetes_role_assumption_config == null
  kubernetes_role_assumption_enabled = var.kubernetes_role_assumption_config != null
}
