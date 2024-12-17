## 2024-12

Rewriting parts which I don't like.

**Work in progress**.

It is assumed that you're working on GNU/Linux or similar environment and you're confident in it.

<del>it is assumed that guest VMs could be destroyed and then recreated from scratch, only the shared Vagrant volume `/vagrant` survives.</del> (my bad idea, since lab 8 it become almost impossible).

* Use Debian images instead of Ubuntu — less memory consumption, less services to disable, no Snap.
* Store all certs in `/vagrant/certs`, which is shared between hosts.
* Use current directory in `cert_verify.sh` instead of hardcoded home directory.
* Use `getent ahosts example.com | cut -d' ' -f1` everywhere because it follows `/etc/nsswitch.conf` rules (reads `/etc/hosts`, mDNS, etc.), instead of `dig +short example.org`.
* Fix typo in `docs/04-certificate-authority.md`: `SERVICE_CIDR` should be `10.96.0.0/16`.
* By some reason, `kubectl` installed with just downloading in some places, but in `docs/09-install-cri-workers.md` it is installed properly with `apt`.
* Add check at the end of `docs/09-install-cri-workers.md`: `vagrant@node01:~$ containerd config dump|grep -i SystemdCgroup`
* No need in `resolvConf` in `docs/10-bootstrapping-kubernetes-workers.md`.
* No need in `resolvConf` in `docs/11-tls-bootstrapping-kubernetes-workers.md`.


## Notes

### If cluster was recreated (disks were destroyed)

* Script `ubuntu/restore_configs_when_node_recreated.sh` will copy most of files which were stored in the shared Vagrant volume `/vagrant`
* Init-files `/etc/systemd/system/etcd.service` have to be recreated, steps are in [07-bootstrapping-etcd.md](docs/07-bootstrapping-etcd.md).
  + `etcd` service have to be enabled and started.
* Init-files have to be recreated on `controlplane01` and `controlplane02` nodes:
  + `/etc/systemd/system/kube-apiserver.service`
  + `/etc/systemd/system/kube-controller-manager.service`
  + `/etc/systemd/system/kube-scheduler.service`
    ```sh
sudo systemctl daemon-reload
sudo systemctl enable kube-apiserver kube-controller-manager kube-scheduler
sudo systemctl start kube-apiserver kube-controller-manager kube-scheduler
```
* Package `haproxy` have to be installed on the `loadbalancer` node, steps are in [08-bootstrapping-kubernetes-controllers.md](docs/08-bootstrapping-kubernetes-controllers.md).

## Probably, mistakes in the original

* `/var/lib/kubernetes/pki/ca.key` have to be copied on controlplane01 and controlplane02.
  + to avoid:
    ```
Dec 11 14:28:22 controlplane02 kube-controller-manager[1399]: E1211 14:28:22.527270    1399 controllermanager.go:771] "Error starting controller" err="failed to start kubernetes.io/kubelet-serving certificate controller: error reading CA cert file \"/var/lib/kubernetes/pki/ca.crt\": open /var/lib/kubernetes/pki/ca.key: no such file or directory" controller="certificatesigningrequest-signing-controller"
Dec 11 14:28:22 controlplane02 kube-controller-manager[1399]: E1211 14:28:22.527297    1399 controllermanager.go:247] "Error starting controllers" err="failed to start kubernetes.io/kubelet-serving certificate controller: error reading CA cert file \"/var/lib/kubernetes/pki/ca.crt\": open /var/lib/kubernetes/pki/ca.key: no such file or directory"
```
* (my mistake, I had to use `kubectl config use-context default --kubeconfig=kube-controller-manager.kubeconfig` in `docs/05-kubernetes-configuration-files.md`) `current-context: "default"` have to be set in `/var/lib/kubernetes/kube-controller-manager.kubeconfig`.
  + to avoid:
    ```
Dec 11 12:42:36 controlplane01 kube-controller-manager[57981]: E1211 12:42:36.251945   57981 run.go:72] "command failed" err="invalid configuration: no configuration has been provided, try setting KUBERNETES_MASTER environment variable"
```
* Add `gpg` and `--no-install-recommends` to `apt-get install -y apt-transport-https ca-certificates curl` in `docs/09-install-cri-workers.md`.

## TODO

* Remove US style capitalization, use [Wikipedia:Naming conventions (capitalization)](https://en.wikipedia.org/wiki/Wikipedia:Naming_conventions_(capitalization)) instead.
* Split `vagrant/ubuntu/ssh.sh` into smaller files?
* Add an example of command like `openssl x509 -noout -text -in kube-apiserver.crt`.
* Add `.yaml` to all `.kubeconfig` filenames.
* Probably no need to create new SSH key on `controlplane01`, just use `ssh -A` to use exist SSH key with agent forwarding.
* No need in `tmux`, just open tabs in terminal.
* Check if commands `kubectl config use-context default --kubeconfig=xxx.kubeconfig` are needed in `docs/05-kubernetes-configuration-files.md` (probably not).
* Use `cp` from `/vagrant/` instead `mv`. This allows to re-create whole cluster.
