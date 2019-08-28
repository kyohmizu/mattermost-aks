cluster:
	terraform init
	terraform apply -state="terraform/terraform.tfstate" -var-file="terraform/terraform.tfvars" terraform/
	terraform output -state="terraform/terraform.tfstate" kube_config > ~/.kube/config
	kubectl create secret generic mattermost-postgresql-password --from-literal postgres-password=$(MATTERMOST_POSTGRES_PASSWORD)
	kubectl apply -f cert/crd/install.yaml

apps:
	kubectl apply -f argo-cd/argocd-ns.yaml
	kubectl apply -n argocd -f argo-cd/install.yaml
	kubectl apply -f argo-cd/app

fqdn:
	$(eval DNSNAME ?= kyohmizu)
	$(eval IP ?= $(shell kubectl get svc nginx-ingress-controller -o=jsonpath='{.status.loadBalancer.ingress[0].ip}'))
	$(eval PUBLICIPID ?= $(shell az network public-ip list --query "[?ipAddress=='$(IP)'].id" -o tsv))
	az network public-ip update --ids $(PUBLICIPID) --dns-name $(DNSNAME)

get-fqdn:
	$(eval IP ?= $(shell kubectl get svc nginx-ingress-controller -o=jsonpath='{.status.loadBalancer.ingress[0].ip}'))
	@echo $(shell az network public-ip list --query "[?ipAddress=='$(IP)'].dnsSettings.fqdn" -o tsv)

get-argocd-pass:
	@kubectl get pods -n argocd -l app.kubernetes.io/name=argocd-server -o name | cut -d'/' -f 2

get-grafana-pass:
	@kubectl get secret grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo

delete-cluster:
	terraform destroy -state="terraform/terraform.tfstate" -var-file="terraform/terraform.tfvars" terraform/
