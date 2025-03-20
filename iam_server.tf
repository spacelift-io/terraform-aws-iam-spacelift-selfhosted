locals {
  server_assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Action    = "sts:AssumeRole"
        Principal = { Service = "ecs-tasks.amazonaws.com" }
      }
    ]
  })

  server_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["s3:AbortMultipartUpload", "s3:DeleteObject", "s3:GetObject", "s3:ListBucket", "s3:PutObject", "s3:PutObjectTagging", "s3:GetObjectVersion", "s3:ListBucketVersions"]
        Resource = [local.states_bucket_arn, "${local.states_bucket_arn}/*"]
      },
      {
        Effect   = "Allow"
        Action   = ["s3:AbortMultipartUpload", "s3:DeleteObject", "s3:GetObject", "s3:PutObject"]
        Resource = [local.uploads_bucket_arn, "${local.uploads_bucket_arn}/*"]
      },
      {
        Effect   = "Allow"
        Action   = ["s3:AbortMultipartUpload", "s3:PutObject"]
        Resource = [local.large_queue_messages_bucket_arn, "${local.large_queue_messages_bucket_arn}/*"]
      }
    ]
  })

  drain_and_server_policy = jsonencode({
    Version = "2012-10-17"
    Statement = concat([
      {
        Effect   = "Allow"
        Action   = ["cloudwatch:PutMetricData"],
        Resource = ["*"],
      },
      {
        Effect   = "Allow"
        Action   = ["sts:AssumeRole"],
        Resource = ["*"],
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket",
          "s3:PutObject",
        ],
        Resource = [
          local.deliveries_bucket_arn,
          "${local.deliveries_bucket_arn}/*",
        ],
      },
      {
        Effect = "Allow"
        Action = [
          "s3:AbortMultipartUpload",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:PutObject",
        ],
        Resource = [
          local.policy_inputs_bucket_arn,
          "${local.policy_inputs_bucket_arn}/*",
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "s3:AbortMultipartUpload",
          "s3:DeleteObject",
          "s3:GetObject",
          "s3:PutObject",
        ],
        Resource = [
          local.user_uploaded_workspaces_bucket_arn,
          "${local.user_uploaded_workspaces_bucket_arn}/*",
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ],
        Resource = [
          local.run_logs_bucket_arn,
          "${local.run_logs_bucket_arn}/*"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "s3:AbortMultipartUpload",
          "s3:PutObject"
        ],
        Resource = [
          local.run_logs_bucket_arn,
          "${local.run_logs_bucket_arn}/*"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "s3:DeleteObject",
          "s3:GetObject",
          "s3:ListBucket",
        ],
        Resource = [
          local.modules_bucket_arn,
          "${local.modules_bucket_arn}/*",
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "s3:AbortMultipartUpload",
          "s3:PutObject"
        ],
        Resource = [
          local.modules_bucket_arn,
          "${local.modules_bucket_arn}/*"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "kms:Decrypt",
          "kms:Encrypt",
          "kms:GenerateDataKey*"
        ],
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
      [{
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

  server = {
    assume_role = local.server_assume_role_policy

    # These are objects so it can be used in a for_each loop easily
    policies = {
      "SERVER"           = local.server_policy,
      "DRAIN_AND_SERVER" = local.drain_and_server_policy
    }
    attachments = {}
  }
}
