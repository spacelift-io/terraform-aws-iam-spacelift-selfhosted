# AGENTS.md

Instructions for AI coding agents and AI code reviewers working in this repository. Humans follow the same rules.

## What this repo is

An output-only Terraform module. It creates no AWS resources. It renders the IAM policy and trust policy JSON for the Spacelift self-hosted services (`server`, `drain`, `scheduler`, `vcs_gateway`, and the ECS-only `execution` role). Customers use the outputs to create their own roles, and the EKS and ECS self-hosted modules pin it as a submodule.

- `iam_server.tf`, `iam_drain.tf`, `iam_scheduler.tf`, `iam_vcs_gateway.tf`, `iam_execution.tf`: one policy per service.
- `iam_drain_and_server.tf`: the policy attached to both `server` and `drain`.
- `main.tf`: resource ARNs built from the inputs, plus the flags that turn optional statements on (`has_sqs_queues`, `has_iot_topic`, `rds_iam_auth_enabled`).
- `PERMISSIONS.md`: the human- and AI-readable reference of every permission. Read the "How to maintain this file" section at its end before you edit it.

## Rule: policy changes come with a `PERMISSIONS.md` change

Any change to a policy statement in `iam_*.tf` must update `PERMISSIONS.md` in the same pull request. That covers adding, removing, or moving an action, a resource, or a whole statement, and changing a condition that makes a statement optional.

Customers use `PERMISSIONS.md` to decide which permissions they need for a given self-hosted version, and which they can skip. Only the author of the change knows which feature uses the permission and whether it is optional, so the author writes the row. It can't be filled in later at release time.

### When you write a change

1. Update the row(s) in `PERMISSIONS.md` for the resource you touched, or add a section if the resource is new.
2. Fill `Needed` honestly. Use `optional: <setting>` only if the backend uses the permission only when that setting is on, and name the setting.
3. If the permission serves several features, list all of them in `Used by`. It is `required` if at least one of them is required.
4. Don't add a version column or version numbers. The file is versioned by the git tag.

### When you review a pull request

Flag it as a blocking issue when:

- an `iam_*.tf` statement changes and `PERMISSIONS.md` doesn't, or
- the `PERMISSIONS.md` change does not match the code: different actions, services, or a module condition that the code doesn't have.

Also point out, without blocking, a `Used by` or `Without it` cell that is vague ("used by the app", "things break") instead of naming the feature and the symptom.

## Other conventions

- Don't add `Sid` to statements in passing. Customers who merge several outputs with `aws_iam_policy_document.source_policy_documents` hit an error on duplicate `Sid`s.
- A removed permission can break older self-hosted versions. Call it out in the PR description.
