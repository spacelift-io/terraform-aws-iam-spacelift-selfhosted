#####################
# Shared Drain and Server Policy
#####################

locals {
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
      }],
      local.has_sqs_queues ? [{
        Effect = "Allow",
        Action = [
          "sqs:SendMessage"
        ],
        Resource = [
          var.sqs_queues.async_jobs,
          var.sqs_queues.events_inbox,
          var.sqs_queues.async_jobs_fifo,
          var.sqs_queues.iot
        ]
      }] : [],
      local.has_iot_topic ? [
        {
          Effect = "Allow",
          Action = [
            "iot:DeleteCertificate",
            "iot:DeletePolicy",
            "iot:DetachPolicy",
            "iot:DetachPrincipalPolicy",
            "iot:UpdateCertificate"
          ],
          Resource = ["*"],
        },
        {
          Effect = "Allow",
          Action = [
            "iot:Publish"
          ],
          Resource = [
            var.iot_topic
          ],
        },
        {
          Effect = "Allow",
          Action = [
            "iot:DescribeCertificate",
            "iot:GetPolicy"
          ],
          Resource = ["*"],
        }
      ] : []
    )
  })
}