ifneq (,$(wildcard ./.env))
    include .env
    export
endif

init: 
	terraform init -lock=false -input=false
plan_destroy:
    terraform plan -destroy -lock=false -input=false -var-file='terraform.tfvars'
destroy:	
	terraform destroy -lock=false -auto-approve
get_kube_config:
	kubectl config get-contexts
	kubectl get nodes
plan:
	terraform plan -lock=false -input=false -var-file="terraform.tfvars"
apply:	
	terraform apply  -lock=false -auto-approve -input=false -var-file="terraform.tfvars"
	terraform output kubeconfig | tr -d '"' | base64 -d > lke-cluster-config.yaml