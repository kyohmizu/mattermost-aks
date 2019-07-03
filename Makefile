helm-values:
ifeq ($(DATASOURCE_POSTGRES), )
	$(error DATASOURCE_POSTGRES is not set)
endif
	envsubst < template/helm/values-mattermost.yaml > helm/values-mattermost.yaml

aks.json:
	envsubst < template/aks-engine/kubernetes.json > aks-engine/kubernetes.json
