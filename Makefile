install-all: install-ingress install-cert-manager create-ns install-apps

install-ingress:
	helm install stable/nginx-ingress --name nginx-ingress --set controller.replicaCount=2

install-cert-manager:
	helm repo add jetstack https://charts.jetstack.io && helm repo update
	kubectl apply -f https://raw.githubusercontent.com/jetstack/cert-manager/release-0.8/deploy/manifests/00-crds.yaml
	kubectl apply -f cert/cert-manager-ns.yaml
	helm install --name cert-manager --namespace cert-manager --version v0.8.1 jetstack/cert-manager

install-apps: mattermost/mattermost.yaml logging/fluent-bit-cm.yaml
	kubectl apply -f mattermost/mattermost.yaml
	kubectl apply -f logging/logging-ns.yaml
	kubectl apply -f logging/fluent-bit-cm.yaml
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
	kubectl get pods -n argocd -l app.kubernetes.io/name=argocd-server -o name | cut -d'/' -f 2

get-grafana-pass:
	kubectl get secret grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo

# Need to run when you create mattermost manifest from values.yaml

helm-values-mattermost:
ifeq ($(DATASOURCE_DB), )
	$(error DATASOURCE_DB is not set)
endif
	mkdir -p mattermost/helm/
	envsubst < mattermost/template/helm/values-mattermost.yaml > mattermost/helm/values-mattermost.yaml

