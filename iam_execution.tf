locals {
  execution_role_assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [local.ecs_role_assumption_statement]
  })

  execution_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
        ]
        Resource = [var.kms_key_arn]
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams",
          "logs:PutLogEvents"
        ],
        Resource = "*"
      },
    ]
  })

  execution = var.kubernetes_role_assumption_config == null ? {
    assume_role = local.execution_role_assume_role_policy

    # These are objects so it can be used in a for_each loop easily
    policies = {
      "EXECUTION" = local.execution_role_policy
    }
    attachments = {
      "AWS_ECS_TASK_EXECUTION" = "arn:${var.aws_partition}:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
    }
  } : null
}
