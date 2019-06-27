helm-values:
ifeq ($(DATASOURCE_POSTGRES), )
	$(error DATASOURCE_POSTGRES is not set)
endif
	envsubst < template/helm/values-mattermost.yaml.template > template/helm/values-mattermost.yaml

test: 
	echo $(DATASOURCE_POSTGRES)
