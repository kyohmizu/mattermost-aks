all: kube-conf helm secret

kube-conf:
	terraform output kube_config > ~/.kube/config

helm:
	helm init

secret:
	kubectl create secret generic mattermost-postgresql-password --from-literal postgres-password=$(MATTERMOST_POSTGRES_PASSWORD)
