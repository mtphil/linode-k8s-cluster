label = "example-lke-cluster"
k8s_version = "1.23"
region = "us-east"
pools = [
    {
        type: "g6-standard-1"
        count: 3
    }
]
vault_address = "https://vault-cluster.vault.f7138e83-ed41-4970-8209-2d60a69c6a0f.aws.hashicorp.cloud:8200"
vault_namespace = "yoyodynecorp"