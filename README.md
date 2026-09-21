# terraform-aws-iam-spacelift-selfhosted

This module helps users create the default IAM roles for use with self hosted Spacelift when users wish to create these roles separately from our standard process.

## Using the module

There are two ways to use this module.

### Usage 1 - Using standard TF resources to create roles

You can use the outputs of this module to create the roles in your own terraform code in any way you see fit.
Below is an example of using the module with standard aws_iam_role, policies, and policy attachments.

```hcl
data "aws_partition" "current" {}

module "self_hosted_roles" {
  source = "github.com/spacelift-io/terraform-aws-iam-spacelift-selfhosted?ref=v1.3.0"

  write_as_files = false
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
  run_observability_bucket_name        = "run-observability-bucket"
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

### Usage 2 - Using the module to create json files on disk

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
  source = "github.com/spacelift-io/terraform-aws-iam-spacelift-selfhosted?ref=v1.3.0"

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
  run_observability_bucket_name        = "run-observability-bucket"
  states_bucket_name                   = "states-bucket"
  uploads_bucket_name                  = "uploads-bucket"
  user_uploaded_workspaces_bucket_name = "user-uploaded-workspaces-bucket"
  workspace_bucket_name                = "workspace-bucket"
}
```

## Message Queue Options

The module supports configuring IAM permissions for two different messaging queue options:

### SQS Queues

You can provide SQS queue ARNs using the `sqs_queues` variable to grant the Spacelift components the necessary permissions to interact with SQS queues:

```hcl
module "self_hosted_roles" {
  source = "github.com/spacelift-io/terraform-aws-iam-spacelift-selfhosted?ref=v1.3.0"

  # Other configuration...

  sqs_queues = {
    deadletter      = "arn:aws:sqs:us-west-2:123456789012:spacelift-dlq"
    deadletter_fifo = "arn:aws:sqs:us-west-2:123456789012:spacelift-dlq.fifo"
    async_jobs      = "arn:aws:sqs:us-west-2:123456789012:spacelift-async-jobs"
    events_inbox    = "arn:aws:sqs:us-west-2:123456789012:spacelift-events-inbox"
    async_jobs_fifo = "arn:aws:sqs:us-west-2:123456789012:spacelift-async-jobs.fifo"
    cronjobs        = "arn:aws:sqs:us-west-2:123456789012:spacelift-cronjobs"
    webhooks        = "arn:aws:sqs:us-west-2:123456789012:spacelift-webhooks"
    iot             = "arn:aws:sqs:us-west-2:123456789012:spacelift-iot"
  }
}
```

### AWS IoT Topic

You can provide an AWS IoT topic ARN using the `iot_topic` variable to grant the Spacelift components the necessary permissions to publish to and manage the topic:

```hcl
module "self_hosted_roles" {
  source = "github.com/spacelift-io/terraform-aws-iam-spacelift-selfhosted?ref=v1.3.0"

  # Other configuration...

  iot_topic = "arn:aws:iot:us-west-2:123456789012:topic/spacelift/readonly/*"
}
```

## RDS IAM Database Authentication

If you run Spacelift against an Aurora cluster with `iam_database_authentication_enabled`, you can let the services authenticate with short-lived IAM auth tokens instead of a static password. Set `rds_iam_auth_config` and the server, drain and VCS gateway policies gain `rds-db:connect` on the database users you list:

```hcl
module "self_hosted_roles" {
  source = "github.com/spacelift-io/terraform-aws-iam-spacelift-selfhosted?ref=v1.3.0"

  # Other configuration...

  rds_iam_auth_config = {
    aws_account_id      = data.aws_caller_identity.current.account_id
    region              = var.region

    # The resource ID of the Aurora cluster, e.g. cluster-ABCDEFGHIJKLMNOPQRSTUVWXYZ.
    # Note that this is not the cluster identifier.
    cluster_resource_id = module.spacelift.rds_cluster_resource_id

    # The database users Spacelift connects as. These need to be granted the
    # rds_iam role inside the database. Do not use the master user here,
    # see below.
    db_usernames = ["spacelift_iam"]
  }
}
```

The IAM policy only covers the token generation side. The database user itself still has to exist and be granted the `rds_iam` role, and neither happens automatically:

```sql
-- The application user. No password, it can only authenticate with an IAM token.
CREATE USER spacelift_iam;

-- rds_iam is a built-in role on every Aurora PostgreSQL cluster. Membership in it
-- is what makes RDS accept an IAM auth token for this user.
GRANT rds_iam TO spacelift_iam;

-- spacelift is the master user, which owns every table the migrations create.
-- This is a role name, not the database name, even though the two happen to match.
-- Without it the new user can connect but cannot read a single table.
GRANT spacelift TO spacelift_iam;
```

The `rds_iam` role is created by RDS on every Aurora PostgreSQL cluster, but no user is a member of it by default, including the user Spacelift connects as. You can check with:

```sql
SELECT pg_has_role('spacelift_iam', 'rds_iam', 'MEMBER');
```

> [!WARNING]
> Do not grant `rds_iam` to the master user (`spacelift` by default). That grant switches the user to IAM-only authentication, so its password stops working - which breaks the running deployment and removes your break-glass access to the database. Create a dedicated user for the application instead, and leave the master user on password authentication.

Inheriting the master role is the low-maintenance option: the new user automatically has access to tables that future migrations create, with nothing to re-grant after an upgrade. It gives up privilege reduction in exchange - `spacelift_iam` ends up as capable as the master user. What it does buy you is that no long-lived password sits on the application's connection path. If you want a narrower grant instead, give the user `SELECT`/`INSERT`/`UPDATE`/`DELETE` on the schema plus `ALTER DEFAULT PRIVILEGES FOR ROLE spacelift`, and keep in mind that this only keeps working while migrations run as the master user.

## ECS vs Kubernetes

By default the module generates roles suitable for usage in ECS. If you want to generate roles that can be assumed by Kubernetes pods instead, populate the `kubernetes_role_assumption_config` variable:

```hcl
data "aws_caller_identity" "current" {}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  # Other cluster configuration...
}

module "kubernetes_roles" {
  source = "github.com/spacelift-io/terraform-aws-iam-spacelift-selfhosted?ref=v1.3.0"

  write_as_files = false

  kubernetes_role_assumption_config = {
    # The ID of the account containing your EKS cluster.
    aws_account_id = data.aws_caller_identity.current.account_id

    oidc_provider = module.eks.oidc_provider

    # The namespace you're deploying the Spacelift components to
    namespace = "spacelift"

    # The service account names you're using for Spacelift
    server_service_account_name    = "spacelift-server"
    drain_service_account_name     = "spacelift-drain"
    scheduler_service_account_name = "spacelift-scheduler"
  }

  # Other configuration...
}
```
