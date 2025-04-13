locals {
  drain_role_assume_role_policy = jsonencode({
    Version = "2012-10-17"

    # We're using concat here even though only one of either ECS or Kubernetes can be enabled because
    # Terraform can't handle different branches of a ternary operator returning different types.
    Statement = concat(
      local.ecs_role_assumption_enabled ? [local.ecs_role_assumption_statement] : [],
      local.kubernetes_role_assumption_enabled ? [{
        Effect = "Allow"
        Principal = {
          Federated = "arn:${var.aws_partition}:iam::${var.kubernetes_role_assumption_config.aws_account_id}:oidc-provider/${var.kubernetes_role_assumption_config.oidc_provider}"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${var.kubernetes_role_assumption_config.oidc_provider}:aud" = "sts.amazonaws.com"
            "${var.kubernetes_role_assumption_config.oidc_provider}:sub" = "system:serviceaccount:${var.kubernetes_role_assumption_config.namespace}:${var.kubernetes_role_assumption_config.drain_service_account_name}"
          }
        }
      }] : []
    )
  })

  drain_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["s3:DeleteObject", "s3:ListBucket"]
        Resource = [local.states_bucket_arn, "${local.states_bucket_arn}/*"]
      },
      {
        Effect   = "Allow"
        Action   = ["s3:AbortMultipartUpload", "s3:DeleteObject", "s3:GetObject", "s3:PutObject"]
        Resource = [local.metadata_bucket_arn, "${local.metadata_bucket_arn}/*"]
      },
      {
        Effect   = "Allow"
        Action   = ["s3:AbortMultipartUpload", "s3:DeleteObject", "s3:GetObject", "s3:PutObject"]
        Resource = [local.workspace_bucket_arn, "${local.workspace_bucket_arn}/*"]
      },
      {
        Effect   = "Allow"
        Action   = ["s3:GetObject"]
        Resource = [local.large_queue_messages_bucket_arn, "${local.large_queue_messages_bucket_arn}/*"]
      },
      {
        Effect   = "Allow"
        Action   = ["s3:PutObjectTagging"]
        Resource = [local.run_logs_bucket_arn, "${local.run_logs_bucket_arn}/*"]
      }
    ]
  })

  drain = {
    assume_role = local.drain_role_assume_role_policy

    # These are objects so it can be used in a for_each loop easily
    policies = {
      "DRAIN"            = local.drain_role_policy,
      "DRAIN_AND_SERVER" = local.drain_and_server_policy
    }
    attachments = {}
  }
}
