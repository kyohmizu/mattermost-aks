install-all: install-cert-manager install-apps install-argocd

install-cert-manager:
#	helm repo add jetstack https://charts.jetstack.io && helm repo update
	kubectl apply -f cert/crd/install.yaml
#	kubectl apply -f cert/cert-manager-ns.yaml
#	helm install --name cert-manager --namespace cert-manager --version v0.8.1 jetstack/cert-manager

install-apps: logging/fluent-bit-cm.yaml
	kubectl apply -f logging/logging-ns.yaml
	kubectl apply -f logging/fluent-bit-cm.yaml

install-argocd:
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
