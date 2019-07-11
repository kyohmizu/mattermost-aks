# Grafana

- Get Password

```bash
kubectl get secret grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
```

## PromQL

- Disk Space

```
node_filesystem_avail_bytes{fstype!~"tmpfs|fuse.lxcfs|squashfs"} / node_filesystem_size_bytes{fstype!~"tmpfs|fuse.lxcfs|squashfs"}
```

- Memory Usage

```
node_memory_Active_bytes / on (kubernetes_node) node_memory_MemTotal_bytes
```

- CPU Usage By Node

```
100 * (1 - avg by(kubernetes_node)(irate(node_cpu_seconds_total{mode='idle'}[5m])))
```

- HTTP Error Rates

```
rate(http_requests_total{status=~"5.."}[5m]) / rate(http_requests_total[5m])
```

- kube-system Container Memory Usage

```
sum (container_memory_usage_bytes{namespace="kube-system"}) by(pod_name)
```

- default-ns Container Memory Usage

```
sum (container_memory_usage_bytes{namespace="default"}) by(pod_name)
```