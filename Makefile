ifneq (,$(wildcard ./.env))
    include .env
    export
endif

init: 
	terraform init -lock=false -input=false
terraform_fmt:
	terraform fmt -check	
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
generate_github_token:
	vault token create -policy=github_actions_reader -format json -namespace admin/yoyodynecorp | jq -r ".auth.client_token"
list_releases:
	curl -u mtphil:${GH_TOKEN} -H "Accept: application/vnd.github.v3+json" https://api.github.com/repos/mtphil/linode-k8s-cluster/releases
create_release:
	curl -u mtphil:${GH_TOKEN} -X POST -H "Accept: application/vnd.github.v3+json" https://api.github.com/repos/mtphil/linode-k8s-cluster/releases \
  		-d '{"tag_name":"${tag}","target_commitish":"main","name":"${tag}", "body":"${description}","draft":false,"prerelease":false,"generate_release_notes":false}'	