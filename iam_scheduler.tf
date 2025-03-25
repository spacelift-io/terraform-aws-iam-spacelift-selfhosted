locals {
  scheduler_assume_role_policy = jsonencode(
    {
      Version = "2012-10-17"
      Statement = [
        {
          Effect    = "Allow"
          Action    = "sts:AssumeRole"
          Principal = { Service = "ecs-tasks.${var.aws_dns_suffix}" }
        }
      ]
    }
  )

  scheduler_policy = jsonencode({
    Version = "2012-10-17"
    Statement = concat(
      [
        {
          Effect   = "Allow"
          Action   = ["cloudwatch:PutMetricData"]
          Resource = ["*"]
        },
        {
          Effect   = "Allow"
          Action   = ["sts:AssumeRole"]
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
      }]
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
