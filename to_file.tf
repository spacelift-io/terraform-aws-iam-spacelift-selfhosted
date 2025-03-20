resource "null_resource" "directory" {
  count = var.write_as_files ? 1 : 0

  provisioner "local-exec" {
    command = "mkdir ./policies"
  }
}

resource "local_file" "drain_role_assume_role_policy" {
  count      = var.write_as_files ? 1 : 0
  depends_on = [null_resource.directory]

  content  = local.drain_role_assume_role_policy
  filename = "./policies/drain_role_assume_role_policy.json"
}

resource "local_file" "drain_role_policy" {
  count      = var.write_as_files ? 1 : 0
  depends_on = [null_resource.directory]

  content  = local.drain_role_policy
  filename = "./policies/drain_role_policy.json"
}

resource "local_file" "drain_and_server_policy" {
  count      = var.write_as_files ? 1 : 0
  depends_on = [null_resource.directory]

  content  = local.drain_and_server_policy
  filename = "./policies/drain_and_server_policy.json"
}

resource "local_file" "execution_role_assume_role_policy" {
  count      = var.write_as_files ? 1 : 0
  depends_on = [null_resource.directory]

  content  = local.execution_role_assume_role_policy
  filename = "./policies/execution_role_assume_role_policy.json"
}

resource "local_file" "execution_role_policy" {
  count      = var.write_as_files ? 1 : 0
  depends_on = [null_resource.directory]

  content  = local.execution_role_policy
  filename = "./policies/execution_role_policy.json"
}

resource "local_file" "scheduler_assume_role_policy" {
  count      = var.write_as_files ? 1 : 0
  depends_on = [null_resource.directory]

  content  = local.scheduler_assume_role_policy
  filename = "./policies/scheduler_assume_role_policy.json"
}

resource "local_file" "scheduler_policy" {
  count      = var.write_as_files ? 1 : 0
  depends_on = [null_resource.directory]

  content  = local.scheduler_policy
  filename = "./policies/scheduler_policy.json"
}

resource "local_file" "server_assume_role_policy" {
  count      = var.write_as_files ? 1 : 0
  depends_on = [null_resource.directory]

  content  = local.server_assume_role_policy
  filename = "./policies/server_assume_role_policy.json"
}

resource "local_file" "server_policy" {
  count      = var.write_as_files ? 1 : 0
  depends_on = [null_resource.directory]

  content  = local.server_policy
  filename = "./policies/server_policy.json"
}