# terraform-aws-iam-spacelift-selfhosted

This module helps users create the default IAM roles for use with self hosted Spacelift when users wish to create these roles separately from our standard process.

There are two ways to use this module.
## Usage 1 - Using standard TF resources to create roles

You can use the outputs of this module to create the roles in your own terraform code in any way you see fit.
Below is an example of using the module with standard aws_iam_role, policies, and policy attachments.

```hcl
data "aws_partition" "current" {}

module "self_hosted_roles" {
  source = "github.com/spacelift-io/terraform-aws-iam-spacelift-selfhosted?ref=v1.0.1"

  write_as_files = false
  aws_partition  = data.aws_partition.current.partition
  aws_dns_suffix = data.aws_partition.current.dns_suffix

  kms_encryption_key_arn               = "arn:aws:kms:us-west-2:123456789012:key/1234abcd-12ab-34cd-56ef-123456789012"
  kms_signing_key_arn                  = "arn:aws:kms:us-west-2:123456789012:key/1234abcd-12ab-34cd-56ef-123456789012"
  kms_key_arn                          = "arn:aws:kms:us-west-2:123456789012:key/1234abcd-12ab-34cd-56ef-123456789012"
  deliveries_bucket_name               = "deliveries-bucket"
  large_queue_messages_bucket_name     = "large-queue-messages-bucket"
  metadata_bucket_name                 = "metadata-bucket"
  modules_bucket_name                  = "modules-bucket"
  policy_inputs_bucket_name            = "policy-inputs-bucket"
  run_logs_bucket_name                 = "run-logs-bucket"
  states_bucket_name                   = "states-bucket"
  uploads_bucket_name                  = "uploads-bucket"
  user_uploaded_workspaces_bucket_name = "user-uploaded-workspaces-bucket"
  workspace_bucket_name                = "workspace-bucket"
}

#####################
# Drain IAM Role
#####################
resource "aws_iam_role" "drain_role" {
  name               = "spacelift-drain-role"
  assume_role_policy = module.self_hosted_roles.drain.assume_role
}

resource "aws_iam_policy" "drain_role" {
  for_each = module.self_hosted_roles.drain.policies

  name   = "${aws_iam_role.drain_role.name}-${each.key}"
  policy = each.value
}

resource "aws_iam_role_policy_attachment" "drain_role" {
  for_each = module.self_hosted_roles.drain.policies

  role       = aws_iam_role.drain_role.name
  policy_arn = aws_iam_policy.drain_role[each.key].arn
}

#####################
# Execution IAM Role
#####################
resource "aws_iam_role" "execution_role" {
  name               = "spacelift-execution-role"
  assume_role_policy = module.self_hosted_roles.execution.assume_role
}

resource "aws_iam_policy" "execution_role" {
  for_each = module.self_hosted_roles.execution.policies

  name   = "${aws_iam_role.execution_role.name}-${each.key}"
  policy = each.value
}

resource "aws_iam_role_policy_attachment" "execution_role" {
  for_each = module.self_hosted_roles.execution.policies

  role       = aws_iam_role.execution_role.name
  policy_arn = aws_iam_policy.execution_role[each.key].arn
}

# Execution role is the only role with an additional policy attachment
resource "aws_iam_role_policy_attachment" "execution_role_extra" {
  for_each = module.self_hosted_roles.execution.attachments

  role       = aws_iam_role.execution_role.name
  policy_arn = each.value
}

#####################
# Scheduler IAM Role
#####################
resource "aws_iam_role" "scheduler_role" {
  name               = "spacelift-scheduler-role"
  assume_role_policy = module.self_hosted_roles.scheduler.assume_role
}

resource "aws_iam_policy" "scheduler_role" {
  for_each = module.self_hosted_roles.scheduler.policies

  name   = "${aws_iam_role.scheduler_role.name}-${each.key}"
  policy = each.value
}

resource "aws_iam_role_policy_attachment" "scheduler_role" {
  for_each = module.self_hosted_roles.scheduler.policies

  role       = aws_iam_role.scheduler_role.name
  policy_arn = aws_iam_policy.scheduler_role[each.key].arn
}

#####################
# Server IAM Role
#####################
resource "aws_iam_role" "server_role" {
  name               = "spacelift-server-role"
  assume_role_policy = module.self_hosted_roles.server.assume_role
}

resource "aws_iam_policy" "server_role" {
  for_each = module.self_hosted_roles.server.policies

  name   = "${aws_iam_role.server_role.name}-${each.key}"
  policy = each.value
}

resource "aws_iam_role_policy_attachment" "server_role" {
  for_each = module.self_hosted_roles.server.policies

  role       = aws_iam_role.server_role.name
  policy_arn = aws_iam_policy.server_role[each.key].arn
}
```

## Usage 2 - Using the module to create json files on disk

Maybe your organization needs to manually provision these roles and you want to just copy and paste the role JSON.
This module can also write the roles to disk as JSON files.

Set `write_as_files = true` and a `policies` directory will be created where you run TF from and inside will be the JSON files for each role.

The following files will be created:

- `./policies/drain_role_assume_role_policy.json`: The assume role policy for the *drain* role.
- `./policies/drain_role_policy.json`: The policy for the *drain* role.
- `./policies/execution_role_assume_role_policy.json`: The assume role policy for the *execution* role.
- `./policies/execution_role_policy.json`: The policy for the *execution* role.
- `./policies/scheduler_role_assume_role_policy.json`: The assume role policy for the *scheduler* role.
- `./policies/scheduler_role_policy.json`: The policy for the *scheduler* role.
- `./policies/server_role_assume_role_policy.json`: The assume role policy for the *server* role.
- `./policies/server_role_policy.json`: The policy for the *server* role.
- `./policies/drain_and_server_policy.json`: An additional policy for the *drain* and *server* roles.

You should also attach the `arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy` policy to the *execution* role.

```hcl
data "aws_partition" "current" {}

module "self_hosted_roles" {
  source = "github.com/spacelift-io/terraform-aws-iam-spacelift-selfhosted?ref=v1.0.0"

  write_as_files = true
  aws_partition  = data.aws_partition.current.partition

  kms_encryption_key_arn               = "arn:aws:kms:us-west-2:123456789012:key/1234abcd-12ab-34cd-56ef-123456789012"
  kms_signing_key_arn                  = "arn:aws:kms:us-west-2:123456789012:key/1234abcd-12ab-34cd-56ef-123456789012"
  kms_key_arn                          = "arn:aws:kms:us-west-2:123456789012:key/1234abcd-12ab-34cd-56ef-123456789012"
  deliveries_bucket_name               = "deliveries-bucket"
  large_queue_messages_bucket_name     = "large-queue-messages-bucket"
  metadata_bucket_name                 = "metadata-bucket"
  modules_bucket_name                  = "modules-bucket"
  policy_inputs_bucket_name            = "policy-inputs-bucket"
  run_logs_bucket_name                 = "run-logs-bucket"
  states_bucket_name                   = "states-bucket"
  uploads_bucket_name                  = "uploads-bucket"
  user_uploaded_workspaces_bucket_name = "user-uploaded-workspaces-bucket"
  workspace_bucket_name                = "workspace-bucket"
}
```