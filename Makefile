# Need to run when you create AKS cluster

install-ingress:
	helm init
	helm install stable/nginx-ingress --name nginx-ingress --set controller.replicaCount=2

fqdn:
ifeq ($(DNSNAME), )
	$(error DNSNAME is not set)
else ifeq ($(PUBLICIPID), )
	$(eval IP ?= $(shell kubectl get svc nginx-ingress-controller -o=jsonpath='{.status.loadBalancer.ingress[0].ip}'))
	$(eval PUBLICIPID := $(shell az network public-ip list --query "[?ipAddress=='$(IP)'].id" -o tsv))
endif
	az network public-ip update --ids $(PUBLICIPID) --dns-name $(DNSNAME)
	export DOMAIN=$(shell az network public-ip list --query "[?ipAddress=='$(IP)'].dnsSettings.fqdn" -o tsv); \
	envsubst < mattermost/template/mattermost-ingress.yaml > mattermost/mattermost-ingress.yaml

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
	kubectl create -f https://raw.githubusercontent.com/fluent/fluent-bit-kubernetes-logging/master/fluent-bit-service-account.yaml
	kubectl create -f https://raw.githubusercontent.com/fluent/fluent-bit-kubernetes-logging/master/fluent-bit-role.yaml
	kubectl create -f https://raw.githubusercontent.com/fluent/fluent-bit-kubernetes-logging/master/fluent-bit-role-binding.yaml
	kubectl apply -f logging/fluent-bit-cm.yaml
	kubectl apply -f logging/fluent-bit-ds.yaml

get-domain:
	$(eval IP ?= $(shell kubectl get svc nginx-ingress-controller -o=jsonpath='{.status.loadBalancer.ingress[0].ip}'))
	@echo $(shell az network public-ip list --query "[?ipAddress=='$(IP)'].dnsSettings.fqdn" -o tsv)

get-grafana-pass:
	kubectl get secret grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo

# Need to run when you create manifest files for your environment

helm-values:
ifeq ($(DATASOURCE_DB), )
	$(error DATASOURCE_DB is not set)
endif
	mkdir -p mattermost/helm/
	envsubst < mattermost/template/helm/values-mattermost.yaml > mattermost/helm/values-mattermost.yaml

manifest-cluster-issuer:
ifeq ($(EMAIL), )
	$(error EMAIL is not set)
endif
	envsubst < cert/template/cluster-issuer.yaml > cert/cluster-issuer.yaml

# Need to run when you reset kubernetes cluster

delete-all-resources:
	kubectl delete -f monitoring/prometheus.yaml
	kubectl delete -f monitoring/grafana.yaml
	kubectl delete -f mattermost/mattermost.yaml
	kubectl delete -f mattermost/mattermost-ingress.yaml
	kubectl delete ns cert-manager
	kubectl delete -f https://raw.githubusercontent.com/Azure/kubernetes-keyvault-flexvol/master/deployment/kv-flexvol-installer.yaml
	kubectl delete secret kvcreds
	kubectl delete ns logging
	helm delete nginx-ingress

