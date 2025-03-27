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

  ecs_role_assumption_statement = var.enable_ecs_role_assumption ? {
    Effect = "Allow"
    Action = "sts:AssumeRole"
    Principal = {
      Service = "ecs-tasks.${var.aws_dns_suffix}"
    }
  } : null

  kubernetes_server_role_assumption_statement = var.enable_kubernetes_role_assumption ? {
    Effect = "Allow"
    Principal = {
      Federated = "arn:aws:iam::${var.kubernetes_config.aws_account_id}:oidc-provider/${var.kubernetes_config.oidc_provider}"
    }
    Action = "sts:AssumeRoleWithWebIdentity"
    Condition = {
      StringEquals = {
        "${var.kubernetes_config.oidc_provider}:aud" = "sts.amazonaws.com"
        "${var.kubernetes_config.oidc_provider}:sub" = "system:serviceaccount:${var.kubernetes_config.namespace}:${var.kubernetes_config.server_service_account_name}"
      }
    }
  } : null

  server_role_assumption_statements = concat(
    var.enable_ecs_role_assumption ? [local.ecs_role_assumption_statement] : [],
    var.enable_kubernetes_role_assumption ? [local.kubernetes_server_role_assumption_statement] : []
  )

  kubernetes_drain_role_assumption_statement = var.enable_kubernetes_role_assumption ? {
    Effect = "Allow"
    Principal = {
      Federated = "arn:aws:iam::${var.kubernetes_config.aws_account_id}:oidc-provider/${var.kubernetes_config.oidc_provider}"
    }
    Action = "sts:AssumeRoleWithWebIdentity"
    Condition = {
      StringEquals = {
        "${var.kubernetes_config.oidc_provider}:aud" = "sts.amazonaws.com"
        "${var.kubernetes_config.oidc_provider}:sub" = "system:serviceaccount:${var.kubernetes_config.namespace}:${var.kubernetes_config.drain_service_account_name}"
      }
    }
  } : null

  drain_role_assumption_statements = concat(
    var.enable_ecs_role_assumption ? [local.ecs_role_assumption_statement] : [],
    var.enable_kubernetes_role_assumption ? [local.kubernetes_drain_role_assumption_statement] : []
  )

  kubernetes_scheduler_role_assumption_statement = var.enable_kubernetes_role_assumption ? {
    Effect = "Allow"
    Principal = {
      Federated = "arn:aws:iam::${var.kubernetes_config.aws_account_id}:oidc-provider/${var.kubernetes_config.oidc_provider}"
    }
    Action = "sts:AssumeRoleWithWebIdentity"
    Condition = {
      StringEquals = {
        "${var.kubernetes_config.oidc_provider}:aud" = "sts.amazonaws.com"
        "${var.kubernetes_config.oidc_provider}:sub" = "system:serviceaccount:${var.kubernetes_config.namespace}:${var.kubernetes_config.scheduler_service_account_name}"
      }
    }
  } : null

  scheduler_role_assumption_statements = concat(
    var.enable_ecs_role_assumption ? [local.ecs_role_assumption_statement] : [],
    var.enable_kubernetes_role_assumption ? [local.kubernetes_scheduler_role_assumption_statement] : []
  )
}
