locals {
  vcs_gateway_assume_role_policy = jsonencode({
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
            "${var.kubernetes_role_assumption_config.oidc_provider}:sub" = "system:serviceaccount:${var.kubernetes_role_assumption_config.namespace}:${var.kubernetes_role_assumption_config.vcs_gateway_service_account_name}"
          }
        }
      }] : []
    )
  })

  vcs_gateway_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["cloudwatch:PutMetricData"]
        Resource = ["*"]
      },
    ]
  })

  vcs_gateway = {
    assume_role = local.vcs_gateway_assume_role_policy
    policies = {
      "VCS_GATEWAY" = local.vcs_gateway_policy
    }
    attachments = {}
  }
}
