locals {
  drain_role_assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "sts:AssumeRole"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
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