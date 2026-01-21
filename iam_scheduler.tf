locals {
  scheduler_assume_role_policy = jsonencode(
    {
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
              "${var.kubernetes_role_assumption_config.oidc_provider}:sub" = "system:serviceaccount:${var.kubernetes_role_assumption_config.namespace}:${var.kubernetes_role_assumption_config.scheduler_service_account_name}"
            }
          }
        }] : []
      )
    }
  )

  scheduler_policy = jsonencode({
    Version = "2012-10-17"
    Statement = concat(
      [
        {
          Effect = "Allow"
          Action = [
            "xray:PutTraceSegments",
            "xray:PutTelemetryRecords",
            "xray:GetSamplingRules",
            "xray:GetSamplingTargets",
            "xray:GetSamplingStatisticSummaries",
            "cloudwatch:PutMetricData",
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
          ]
          Resource = "*"
        },
        {
          Effect   = "Allow"
          Action   = ["sts:AssumeRole", "sts:TagSession"]
          Resource = ["*"]
        },
        {
          Effect = "Allow"
          Action = [
            "kms:Decrypt",
            "kms:Encrypt",
            "kms:GenerateDataKey*",
          ]
          Resource = [var.kms_key_arn]
        }
      ],
      [{
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:Encrypt",
          "kms:GenerateDataKey*",
        ]
        Resource = [var.kms_encryption_key_arn]
      }],
      var.kms_signing_key_arn == null ? [] : [{
        Effect = "Allow"
        Action = [
          "kms:GetPublicKey",
          "kms:Sign",
          "kms:Verify",
        ]
        Resource = [var.kms_signing_key_arn]
      }],
      local.has_sqs_queues ? [{
        Effect = "Allow",
        Action = [
          "sqs:SendMessage"
        ],
        Resource = [var.sqs_queues.cronjobs]
      }] : [],
    )
  })

  scheduler = {
    assume_role = local.scheduler_assume_role_policy

    # These are objects so it can be used in a for_each loop easily
    policies = {
      "SCHEDULER" = local.scheduler_policy
    }
    attachments = {}
  }
}
