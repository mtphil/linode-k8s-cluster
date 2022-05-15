# linode-k8s-cluster

### Makefile

The Makefile contains all necessary commands to create a k8s cluster locally when paired with an `.env` file containing all necessary credentials.

It also contains commands to list all releases on Github, as well as publishing a new release, which triggers a Github Action Workflow on the terraform files included in this repository.

### Terraform
Terraform is configured to use Consul as a backend state store. 

### Github Action Workflow
When triggered by a published release, the GitHub action Workflow reaches out to a Vault server to retrieve credentials for both Consul and Linode and then runs `terraform fmt`, `terraform plan` and `terraform apply`. 

Else on all pull requests, `terraform fmt` and `terraform plan` are run to verify correctness.
