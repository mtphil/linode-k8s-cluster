ifneq (,$(wildcard ./.env))
    include .env
    export
endif

########### terraform actions #################
init: 
	terraform init -lock=false -input=false
terraform_fmt:
	terraform fmt -check	
plan_destroy:
	terraform plan -destroy -lock=false -input=false -var-file='terraform.tfvars'
destroy:
	terraform destroy -lock=false -auto-approve
plan:
	terraform plan -lock=false -input=false -var-file="terraform.tfvars"
apply:
	terraform apply  -lock=false -auto-approve -input=false -var-file="terraform.tfvars"
	terraform output kubeconfig | tr -d '"' | base64 -d > ~/.kube/config
###########################################

############ github actions ###############
generate_new_vault_token_for_github:
	vault token create -policy=github_actions_reader -format json -ttl 72h -namespace admin/yoyodynecorp | jq -r ".auth.client_token"
list_releases:
	curl -u mtphil:${GH_TOKEN} -H "Accept: application/vnd.github.v3+json" https://api.github.com/repos/mtphil/linode-k8s-cluster/releases | jq '.[].name'
create_release:
	curl -u mtphil:${GH_TOKEN} -X POST -H "Accept: application/vnd.github.v3+json" https://api.github.com/repos/mtphil/linode-k8s-cluster/releases \
  		-d '{"tag_name":"${tag}","target_commitish":"main","name":"${tag}", "body":"${description}","draft":false,"prerelease":false,"generate_release_notes":false}'
make_pr:
	gh pr create -f -t ${PR_TITLE}
#######################################

############ linting ##################	
yaml_lint:
	yamllint .
#######################################


############ emissary apply ###########
kubectl_apply_emissary:
	terraform output kubeconfig | tr -d '"' | base64 -d > ~/.kube/config
	helm repo add datawire https://app.getambassador.io
	helm repo update
	kubectl create namespace emissary
	kubectl apply -f https://app.getambassador.io/yaml/emissary/2.2.2/emissary-crds.yaml
	kubectl wait --timeout=90s --for=condition=available deployment emissary-apiext -n emissary-system
	helm install -n emissary --create-namespace emissary-ingress datawire/emissary-ingress && kubectl rollout status  -n emissary deployment/emissary-ingress -w
	kubectl apply -f k8s_yaml/emissary_crd_mapping.yaml
#######################################


############# argocd actions ################
get_kube_config:
	kubectl config get-contexts
	kubectl get nodes
kubectl_apply_argocd:
	kubectl create namespace argocd
	kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl_port_forward_argocd:
	kubectl port-forward svc/argocd-server -n argocd 8080:443
kubectl_argocd_login:
	argocd login localhost:8080
kubectl_argocd_add_cluster:
	argocd cluster add ${cluster}	
kubectl_get_initial_argo_admin_creds:
	kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d > creds
kubectl_argocd_add_application:
	argocd app create ${appname} --repo https://github.com/mtphil/${reponame}.git --path ${appname} --dest-server https://kubernetes.default.svc --dest-namespace default
kubectl_argocd_get_application_status:
	argocd app get ${appname}
kubectl_argocd_application_sync:
	argocd app sync	${appname}