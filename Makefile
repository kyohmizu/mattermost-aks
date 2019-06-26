mattermost-config:
	envsubst < template/mattermost-config.yaml.template > manifests/mattermost-config.yaml
