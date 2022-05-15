# linode-k8s-cluster

## General

This repository contains both:

1) a `Makefile` with a suite of commands suited to creating, and tearing down, a `Kubernetes` cluster on Linode via `Terraform`.

2) a Github Action Workflow which runs `terraform apply` on this repository's `.tf` files when a new `Release` is published, thus either creating a new or updating a pre-existing `Kubernetes` cluster on `Linode` with changes.

## Makefile

The `Makefile` contains all necessary commands to create a k8s cluster locally when paired with an `.env` file containing all necessary credentials.

Required environment variables:

`VAULT_ADDR`

`VAULT_NAMESPACE`

`VAULT_TOKEN`

`CONSUL_HTTP_TOKEN`

`TF_VAR_LINODE_KUBERNETES_API_TOKEN`

`KUBECONFIG`

`GH_TOKEN`

It also contains commands to list all releases on Github, as well as publishing a new `Release`, which triggers a Github Action Workflow on the terraform files included in this repository.

## Terraform

`Terraform` is configured to use `Consul` as a backend state store.

## Github Action Workflow

When triggered by a published release, the GitHub action Workflow reaches out to a `Vault` server to retrieve credentials for both `Consul` (`secret/data/github_action_linode_terraform CONSUL_API_TOKEN`) and `Linode` (`secret/data/github_action_linode_terraform LINODE_KUBERNETES_API_TOKEN`) and then runs `terraform fmt`, `terraform plan` and `terraform apply`.

Else on all pull requests, `terraform fmt` and `terraform plan` are run to verify correctness.
