helm-values:
	ifeq ($(DATASOURCE_POSTGRES), "")
		$(error DATASOURCE_POSTGRES is required)
	endif
	envsubst < template/helm/values-mattermost.yaml.template > template/helm/values-mattermost.yaml
