# linode-k8s-cluster

## General

This repository contains:

1) the minimum `Terraform` scaffolding necessary to spin up a `Kubernetes` cluster on `Linode`.

2) a `Makefile` with a suite of commands for creating, and tearing down, a `Kubernetes` cluster on Linode via these `.tf` files on a local machine.

3) a Github Action Workflow which runs `terraform apply` on this repository's `.tf` files when a new `Release` is published, thus either creating a new or updating a pre-existing `Kubernetes` cluster on `Linode` with that `Release`'s changes.

## Makefile

### Configuration

The `Makefile` must be paired with an `.env` file containing all necessary credentials, which are:

`VAULT_ADDR`\
`VAULT_NAMESPACE`\
`VAULT_TOKEN`\
`CONSUL_HTTP_TOKEN`\
`TF_VAR_LINODE_KUBERNETES_API_TOKEN`\
`KUBECONFIG`\
`GH_TOKEN`

### Commands 

- `init` runs `terraform init`
- `terraform_fmt` runs `terraform fmt`
- `plan_destroy` runs `terraform plan -destroy`
- `destroy` runs `terraform destroy`
- `get_kube_config` gets the kubeconfig file for a newly created `Kubernetes` cluster
- `plan` runs `terraform plan`
- `apply` runs `terraform apply`
- `generate_new_vault_token_for_github` generates a new `VAULT_TOKEN`
- `list_releases` lists all Github `Release`s for this repo
- `create_release` creates a new published `Release`on github, taking two arguments: 
    1) `tag='v0.0.0'` - the version number for the release in Semver 
    2) `description='text'` - the description string for the `Release`

## Terraform

`main.tf` is configured to use `Consul` as a backend state store and `Linode` as its sole `Provider`.

## Github Action Workflow

When triggered by a published release, the GitHub action Workflow reaches out to a `Vault` server to retrieve credentials for both `Consul` nd `Linode` and then runs `terraform fmt`, `terraform plan` and `terraform apply`.

This is [the relevant part of the Workflow](https://github.com/mtphil/linode-k8s-cluster/blob/main/.github/workflows/terraform-apply.yaml) which must be configured with a `Vault` endpoint url and API token as well as the precise paths of the secrets to be fetched: 

```
      - uses: hashicorp/vault-action@v2.4.0
        with:
          url: ${{ env.vault_endpoint}}
          tlsSkipVerify: true
          method: token
          namespace: admin/yoyodynecorp
          token: ${{ secrets.VAULT_API_TOKEN }}
          secrets: |
            secret/data/github_action_linode_terraform LINODE_KUBERNETES_API_TOKEN ;
            secret/data/github_action_linode_terraform CONSUL_API_TOKEN
```            

Else on all pull requests, `terraform fmt` and `terraform plan` are run to verify correctness.
