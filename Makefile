fqdn:
ifeq ($(DNSNAME), )
        $(error DNSNAME is not set)
else ifeq ($(PUBLICIPID), )
ifeq ($(IP), )
	$(error IP is not set)
endif
	$(eval PUBLICIPID := $(shell az network public-ip list --query "[?ipAddress!=null]|[?contains(ipAddress, '$(IP)')].[id]" --output tsv))
endif
	az network public-ip update --ids $(PUBLICIPID) --dns-name $(DNSNAME)

helm-values:
ifeq ($(DATASOURCE_POSTGRES), )
	$(error DATASOURCE_POSTGRES is not set)
endif
	envsubst < template/helm/values-mattermost.yaml > helm/values-mattermost.yaml

manifests:
	make manifest-mattermost
	make manifest-cluster-issuer
	make manifest-mattermost-ingress

manifest-mattermost:
ifeq ($(ARM_SUBSCRIPTION_ID), )
	$(error ARM_SUBSCRIPTION_ID is not set)
else ifeq ($(ARM_TENANT_ID), )
	$(error ARM_TENANT_ID is not set)
endif
	envsubst < template/manifests/mattermost.yaml > manifests/mattermost.yaml

manifest-cluster-issuer:
ifeq ($(EMAIL), )
	$(error EMAIL is not set)
endif
	envsubst < template/manifests/cluster-issuer.yaml > manifests/cluster-issuer.yaml

manifest-mattermost-ingress:
ifeq ($(DOMAIN), )
	$(error DOMAIN is not set)
endif
	envsubst < template/manifests/mattermost-ingress.yaml > manifests/mattermost-ingress.yaml

enable-vault:
ifeq ($(ARM_CLIENT_ID), )
	$(error ARM_CLIENT_ID is not set)
else ifeq ($(ARM_CLIENT_SECRET), )
	$(error ARM_CLIENT_SECRET is not set)
endif
	kubectl create -f https://raw.githubusercontent.com/Azure/kubernetes-keyvault-flexvol/master/deployment/kv-flexvol-installer.yaml
	kubectl create secret generic kvcreds --from-literal clientid=$(ARM_CLIENT_ID) --from-literal clientsecret=$(ARM_CLIENT_SECRET) --type=azure/kv

assign-role:
ifeq ($(ARM_SUBSCRIPTION_ID), )
	$(error ARM_SUBSCRIPTION_ID is not set)
else ifeq ($(ARM_CLIENT_ID), )
	$(error ARM_CLIENT_ID is not set)
else ifeq ($(KV_NAME), )
	$(error KV_NAME is not set)
else ifeq ($(KV_RSGROUP_NAME), )
	$(error KV_RSGROUP_NAME is not set)
endif
	az role assignment create --role Reader --assignee $(ARM_CLIENT_ID) --scope /subscriptions/$(ARM_SUBSCRIPTION_ID)/resourcegroups/$(KV_RSGROUP_NAME)/providers/Microsoft.KeyVault/vaults/$(KV_NAME)
	az keyvault set-policy -n $(KV_NAME) --key-permissions get --spn $(ARM_CLIENT_ID)
	az keyvault set-policy -n $(KV_NAME) --secret-permissions get --spn $(ARM_CLIENT_ID)
	az keyvault set-policy -n $(KV_NAME) --certificate-permissions get --spn $(ARM_CLIENT_ID)

helm-update:
	helm repo add jetstack https://charts.jetstack.io
	helm repo update

install-ingress:
	helm install stable/nginx-ingress --set controller.replicaCount=2

install-cert-manager:
	kubectl apply -f https://raw.githubusercontent.com/jetstack/cert-manager/release-0.8/deploy/manifests/00-crds.yaml
	kubectl create namespace cert-manager
	kubectl label namespace cert-manager certmanager.k8s.io/disable-validation=true
	helm install --name cert-manager --namespace cert-manager --version v0.8.1 jetstack/cert-manager

kubernetes.json:
ifeq ($(ARM_CLIENT_ID), )
	$(error ARM_CLIENT_ID is not set)
else ifeq ($(ARM_CLIENT_SECRET), )
	$(error ARM_CLIENT_SECRET is not set)
endif
	mkdir aks-engine
	envsubst < template/aks-engine/kubernetes.json > aks-engine/kubernetes.json

create-cluster: aks-engine/kubernetes.json
	aks-engine deploy --subscription-id $(ARM_SUBSCRIPTION_ID) --client-id $(ARM_CLIENT_ID) --client-secret $(ARM_CLIENT_SECRET) --location japaneast --api-model aks-engine/kubernetes.json
