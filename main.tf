terraform {
    required_providers {
        linode = {
            source = "linode/linode"
            version = "1.27.1"
        }
    }
}

terraform {
  required_providers {
    vault = {
      source = "hashicorp/vault"
      version = "3.5.0"
    }
  }
}

provider "vault" {
  address = var.vault_address
  namespace = var.vault_namespace
  token = var.VAULT_TOKEN
}

provider "linode" {
    token = var.token
}

resource "linode_lke_cluster" "foobar" {
    k8s_version = var.k8s_version
    label = var.label
    region = var.region
    tags = var.tags

    dynamic "pool" {
        for_each = var.pools
        content {
            type = pool.value["type"]
            count = pool.value["count"]
        }
    }
}

output "kubeconfig" {
    value = linode_lke_cluster.foobar.kubeconfig
    sensitive = true
}

output "apit_endpoints" {
    value = linode_lke_cluster.foobar.api_endpoints
}

output "status" {
    value = linode_lke_cluster.foobar.status
}

output "id" {
    value = linode_lke_cluster.foobar.id
}

output "pool" {
    value = linode_lke_cluster.foobar.pool
}

variable "name" { default = "dynamic-aws-creds-operator" }
variable "path" { default = "../vault-admin-workspace/terraform.tfstate" }
variable "ttl" { default = "1" }

terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}

data "terraform_remote_state" "admin" {
  backend = "local"

  config = {
    path = var.path
  }
}

data "vault_aws_access_credentials" "creds" {
  backend = data.terraform_remote_state.admin.outputs.backend
  role    = data.terraform_remote_state.admin.outputs.role
}

provider "aws" {
  region     = var.region
  access_key = data.vault_aws_access_credentials.creds.access_key
  secret_key = data.vault_aws_access_credentials.creds.secret_key
}