kubeconf:
	terraform output kube_config > ~/.kube/config

fluent-bit-config:
	export FLUENT_AZURE_WORKSPACE_ID=$(terraform output ala_workspace_id)
	export FLUENT_AZURE_WORKSPACE_KEY=$(terraform output ala_shared_key)
	envsubst < ../logging/template/fluent-bit-cm.yaml > ../logging/fluent-bit-cm.yaml
