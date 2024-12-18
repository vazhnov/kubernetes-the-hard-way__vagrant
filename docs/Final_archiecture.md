controlplane01, controlplane02:
* etcd v3.5.9: port 2379, 2380
* kube-apiserver: port 6443
* kube-scheduler: port 10259
* kube-controller-manager: port 10257

loadbalancer:
* `haproxy` in `mode tcp`, without any certificates. Port 6443

node01, node02:
* containerd: `/var/run/containerd/containerd.sock`
* kubelet (node02 — with TLS bootstrapping).
* kube-proxy

In pods:
* CNI:
* DNS: CoreDNS v1.9.4.
