helm-values:
ifeq ($(DATASOURCE_POSTGRES), )
	$(error DATASOURCE_POSTGRES is not set)
endif
	envsubst < template/helm/values-mattermost.yaml > helm/values-mattermost.yaml

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
