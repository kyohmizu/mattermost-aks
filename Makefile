helm-values:
ifeq ($(DATASOURCE_POSTGRES), )
	$(error DATASOURCE_POSTGRES is not set)
endif
	envsubst < template/helm/values-mattermost.yaml > helm/values-mattermost.yaml

manifests:
ifeq ($(ARM_SUBSCRIPTION_ID), )
	$(error ARM_SUBSCRIPTION_ID is not set)
else ifeq ($(ARM_TENANT_ID), )
	$(error ARM_TENANT_ID is not set)
endif
	envsubst < template/manifests/mattermost.yaml > manifests/mattermost.yaml

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
