install-ingress:
	helm init && sleep 100
	helm install stable/nginx-ingress --name nginx-ingress --set controller.replicaCount=2

fqdn:
	$(eval DNSNAME ?= kyohmizu)
	$(eval IP ?= $(shell kubectl get svc nginx-ingress-controller -o=jsonpath='{.status.loadBalancer.ingress[0].ip}'))
	$(eval PUBLICIPID ?= $(shell az network public-ip list --query "[?ipAddress=='$(IP)'].id" -o tsv))
	az network public-ip update --ids $(PUBLICIPID) --dns-name $(DNSNAME)

install-cert-manager:
	helm repo add jetstack https://charts.jetstack.io && helm repo update
	kubectl apply -f https://raw.githubusercontent.com/jetstack/cert-manager/release-0.8/deploy/manifests/00-crds.yaml
	kubectl create namespace cert-manager
	kubectl label namespace cert-manager certmanager.k8s.io/disable-validation=true
	helm install --name cert-manager --namespace cert-manager --version v0.8.1 jetstack/cert-manager

install-tools: install-monitoring install-fluent-bit

install-monitoring:
	kubectl apply -f monitoring/prometheus.yaml
	kubectl apply -f monitoring/grafana.yaml

install-fluent-bit: logging/fluent-bit-cm.yaml
	kubectl create namespace logging
	kubectl apply -f logging/fluent-bit-cm.yaml
	kubectl apply -f logging/fluent-bit.yaml

get-domain:
	$(eval IP ?= $(shell kubectl get svc nginx-ingress-controller -o=jsonpath='{.status.loadBalancer.ingress[0].ip}'))
	@echo $(shell az network public-ip list --query "[?ipAddress=='$(IP)'].dnsSettings.fqdn" -o tsv)

get-grafana-pass:
	kubectl get secret grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo

# Need to run when you create mattermost manifest from values.yaml

helm-values-mattermost:
ifeq ($(DATASOURCE_DB), )
	$(error DATASOURCE_DB is not set)
endif
	mkdir -p mattermost/helm/
	envsubst < mattermost/template/helm/values-mattermost.yaml > mattermost/helm/values-mattermost.yaml

