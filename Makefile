# Step1
install: cluster secret cert-manager argocd

# Step2
publish: cert fqdn

cluster:
	terraform init
	terraform apply -state="terraform/terraform.tfstate" -var-file="terraform/terraform.tfvars" terraform/
	terraform output -state="terraform/terraform.tfstate" kube_config > ~/.kube/config

secret:
	kubectl create secret generic mattermost-postgresql-password --from-literal postgres-password=$(MATTERMOST_POSTGRES_PASSWORD)

cert-manager:
	kubectl apply -f cert/crd/install.yaml
	kubectl apply -f cert/cert-manager-ns.yaml
	kubectl apply -f cert/cert-manager.yaml

argocd:
	kubectl apply -f argo-cd/argocd-ns.yaml
	kubectl apply -n argocd -f argo-cd/install.yaml
	kubectl apply -f argo-cd/app

cert:
	kubectl apply -f cert/cluster-issuer.yaml
	kubectl apply -f cert/ingress.yaml

fqdn:
	$(eval DNSNAME ?= kyohmizu)
	$(eval IP ?= $(shell kubectl get svc nginx-ingress-controller -o=jsonpath='{.status.loadBalancer.ingress[0].ip}'))
	$(eval PUBLICIPID ?= $(shell az network public-ip list --query "[?ipAddress=='$(IP)'].id" -o tsv))
	az network public-ip update --ids $(PUBLICIPID) --dns-name $(DNSNAME)

fqdn-concourse:
	$(eval DNSNAME_CI ?= kyohmizu-concourse)
	$(eval IP ?= $(shell kubectl get svc concourse-web -o=jsonpath='{.status.loadBalancer.ingress[0].ip}'))
	$(eval PUBLICIPID ?= $(shell az network public-ip list --query "[?ipAddress=='$(IP)'].id" -o tsv))
	az network public-ip update --ids $(PUBLICIPID) --dns-name $(DNSNAME_CI)

# Get values
get-fqdn:
	$(eval IP ?= $(shell kubectl get svc nginx-ingress-controller -o=jsonpath='{.status.loadBalancer.ingress[0].ip}'))
	@echo $(shell az network public-ip list --query "[?ipAddress=='$(IP)'].dnsSettings.fqdn" -o tsv)

get-fqdn-concourse:
	$(eval IP ?= $(shell kubectl get svc concourse-web -o=jsonpath='{.status.loadBalancer.ingress[0].ip}'))
	@echo $(shell az network public-ip list --query "[?ipAddress=='$(IP)'].dnsSettings.fqdn" -o tsv)

get-argocd-pass:
	@kubectl get pods -n argocd -l app.kubernetes.io/name=argocd-server -o name | cut -d'/' -f 2

get-grafana-pass:
	@kubectl get secret grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo

# Delete cluster
delete:
	terraform destroy -state="terraform/terraform.tfstate" -var-file="terraform/terraform.tfvars" terraform/

# Concourse CI
set-pipeline:
	fly -t test sp -c concourse-ci/portfolio.yaml -p portfolio -v github_project_key="$${GITHUB_KEY}" -v app_branch=$${BRANCH} -v dockerhub_password=$${DOCKERHUB_PASSWD}
