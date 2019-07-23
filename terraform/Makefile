all: kube-conf vault manifests

kube-conf:
	terraform output kube_config > ~/.kube/config

vault:
	#envsubst < ../mattermost/template/config > ../mattermost/config
	#az keyvault secret set -n config --vault-name $(shell terraform output kv_name) --file ../mattermost/config --subscription $(ARM_SUBSCRIPTION_ID)
	kubectl create -f https://raw.githubusercontent.com/Azure/kubernetes-keyvault-flexvol/master/deployment/kv-flexvol-installer.yaml
	kubectl create secret generic kvcreds --from-literal clientid=$(ARM_CLIENT_ID) --from-literal clientsecret=$(ARM_CLIENT_SECRET) --type=azure/kv

manifests: mattermost fluent-bit-cm

mattermost:
	export RSGROUP=$(shell terraform output rsgroup); \
	export KV_NAME=$(shell terraform output kv_name); \
	envsubst < ../mattermost/template/mattermost.yaml > ../mattermost/mattermost.yaml

fluent-bit-cm:
	export FLUENT_AZURE_WORKSPACE_ID=$(shell terraform output ala_workspace_id); \
	export FLUENT_AZURE_WORKSPACE_KEY=$(shell terraform output ala_shared_key); \
	envsubst < ../logging/template/fluent-bit-cm.yaml > ../logging/fluent-bit-cm.yaml
