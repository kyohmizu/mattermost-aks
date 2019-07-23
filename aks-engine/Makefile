kubernetes.json:
ifeq ($(ARM_CLIENT_ID), )
	$(error ARM_CLIENT_ID is not set)
else ifeq ($(ARM_CLIENT_SECRET), )
	$(error ARM_CLIENT_SECRET is not set)
endif
	mkdir aks-engine
	envsubst < template/kubernetes.json > kubernetes.json

create-cluster: kubernetes.json
	aks-engine deploy --subscription-id $(ARM_SUBSCRIPTION_ID) --client-id $(ARM_CLIENT_ID) --client-secret $(ARM_CLIENT_SECRET) --location japaneast --api-model kubernetes.json
