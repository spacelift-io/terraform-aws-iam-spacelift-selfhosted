locals {
  flows_enabled    = var.flows_bucket_name != null && var.flows_bucket_name != ""
  flows_bucket_arn = local.flows_enabled ? "arn:${var.aws_partition}:s3:::${var.flows_bucket_name}" : ""

  flows_assume_role_policy = jsonencode({
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
            "${var.kubernetes_role_assumption_config.oidc_provider}:sub" = "system:serviceaccount:${var.kubernetes_role_assumption_config.namespace}:${var.kubernetes_role_assumption_config.flows_service_account_name}"
          }
        }
      }] : []
    )
  })

  # Flows only talks to its own bucket, so unlike the other roles it gets no
  # access to the Spacelift buckets, queues or KMS keys. The only key it can
  # use is the one its bucket is encrypted with.
  flows_policy = jsonencode({
    Version = "2012-10-17"
    Statement = concat(
      [{
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket",
          "s3:ListBucketVersions",
          "s3:GetBucketLocation",
          "s3:GetBucketVersioning",
        ]
        Resource = [local.flows_bucket_arn, "${local.flows_bucket_arn}/*"]
      }],
      var.flows_kms_key_arn == null ? [] : [{
        Effect   = "Allow"
        Action   = ["kms:GenerateDataKey", "kms:Decrypt", "kms:DescribeKey"]
        Resource = [var.flows_kms_key_arn]
      }]
    )
  })

  flows = local.flows_enabled ? {
    assume_role = local.flows_assume_role_policy
    policies = {
      "FLOWS" = local.flows_policy
    }
    attachments = {}
  } : null
}
