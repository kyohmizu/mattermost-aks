# Deploy mattermost on AKS

## Prerequisite

You need to create Database (PostgreSQL) earlier.
I use Azure Database for PostgreSQL server.

## Create AKS cluster

```bash
$ cd terraform
$ terraform init
$ terraform apply
```

## Deploy kubernetes resources

Need to install mattermost with helm for your enviroment:

```
$ DATASOURCE_POSTGRES="postgres://<USERNAME>:<PASSWORD>@<HOST>:5432/<DATABASE_NAME>?sslmode=disable&connect_timeout=10" make helm-values
$ helm init
$ helm install -n mattermost -f template/helm/values-mattermost.yaml stable/mattermost-team-edition
```

Apply other resources:

```bash
$ cd manifests
$ kubectl apply -f prometheus.yaml
$ kubectl apply -f grafana.yaml

# test if mattermost is running
$ kubectl apply -f test/test-mattermost.yaml
```

## Grafana settings

Get login password:

```bash
$ kubectl get secret grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
```
