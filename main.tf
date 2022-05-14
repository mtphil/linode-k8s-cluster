terraform {
  required_providers {
    linode = {
      source  = "linode/linode"
      version = "1.27.1"
    }
  }
}

terraform {
  backend "consul" {
    address = "https://consul-cluster.consul.f7138e83-ed41-4970-8209-2d60a69c6a0f.aws.hashicorp.cloud"
    scheme  = "https"
    path    = "yoyodynecorp/terraform_state"
  }
}

provider "linode" {
  token = var.LINODE_KUBERNETES_API_TOKEN
}

resource "linode_lke_cluster" "k8s_cluster" {
  k8s_version = var.k8s_version
  label       = var.label
  region      = var.region
  tags        = var.tags

  dynamic "pool" {
    for_each = var.pools
    content {
      type  = pool.value["type"]
      count = pool.value["count"]
    }
  }
}

output "kubeconfig" {
  value     = linode_lke_cluster.k8s_cluster.kubeconfig
  sensitive = true
}

output "apit_endpoints" {
  value = linode_lke_cluster.k8s_cluster.api_endpoints
}

output "status" {
  value = linode_lke_cluster.k8s_cluster.status
}

output "id" {
  value = linode_lke_cluster.k8s_cluster.id
}

output "pool" {
  value = linode_lke_cluster.k8s_cluster.pool
}