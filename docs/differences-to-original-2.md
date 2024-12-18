## 2024-12

Rewriting parts which I don't like.

**Work in progress**.

It is assumed that you're working on GNU/Linux or similar environment and you're confident in it.

### About original

This branch code is based on https://github.com/mmumshad/kubernetes-the-hard-way, the last commit was https://github.com/mmumshad/kubernetes-the-hard-way/commit/e76cb25fa0bea2c91eab306be75e28a00e2961ca <time>2024-09-04</time>,
which in turn is based on https://github.com/kelseyhightower/kubernetes-the-hard-way, the last commit was https://github.com/kelseyhightower/kubernetes-the-hard-way/commit/bf2850974e19c118d04fdc0809ce2ae8a0026a27 <time>2018-09-30</time>, [diff to the latest](https://github.com/kelseyhightower/kubernetes-the-hard-way/compare/bf2850974e19c118d04fdc0809ce2ae8a0026a27..master).

### Done

+ Use Debian images instead of Ubuntu — less memory consumption, less services to disable, no Snap.
+ Use current directory in `cert_verify.sh` instead of hardcoded home directory.
+ Use `getent ahosts example.com | cut -d' ' -f1` everywhere because it follows `/etc/nsswitch.conf` rules (reads `/etc/hosts`, mDNS, etc.), instead of `dig +short example.org`, see https://github.com/mmumshad/kubernetes-the-hard-way/issues/355.
+ Fix typo in `docs/04-certificate-authority.md`: `SERVICE_CIDR` should be `10.96.0.0/16`.
+ No need in `resolvConf` in `docs/10-bootstrapping-kubernetes-workers.md` and in `docs/11-tls-bootstrapping-kubernetes-workers.md`.
+ Add `gpg` and `--no-install-recommends` to `apt-get install -y apt-transport-https ca-certificates curl` in `docs/09-install-cri-workers.md`.

### Versions

Tested with:
* Host machine: Debian GNU/Linux 12 (bookworm).
* Guest machines: Debian GNU/Linux 12 (bookworm).
* etcd: v3.5.9 (from https://github.com/coreos/etcd/releases).
* Kubernetes (`kubectl`, ): v1.31.3 (from https://prod-cdn.packages.k8s.io).
* containerd: 1.6.20 (from https://packages.debian.org/bookworm/amd64/containerd).
* kubernetes-cni: 1.5.1 (from https://prod-cdn.packages.k8s.io).

### TODO

* Remove US style capitalization, use [Wikipedia:Naming conventions (capitalization)](https://en.wikipedia.org/wiki/Wikipedia:Naming_conventions_(capitalization)) instead.
* Split `vagrant/ubuntu/ssh.sh` into smaller files?
* Add an example of command like `openssl x509 -noout -text -in kube-apiserver.crt` (see also command `openssl x509 -in <certificate path> -text` in `tools/kubernetes-certs-checker.xlsx`).
* Add `.yaml` to all `.kubeconfig` filenames.
* Probably no need to create new SSH key on `controlplane01`, just use `ssh -A` to use exist SSH key with agent forwarding.
* No need in `tmux`, just open tabs in terminal.
* Check if commands `kubectl config use-context default --kubeconfig=xxx.kubeconfig` are needed in `docs/05-kubernetes-configuration-files.md` (probably not).
* Store all certs in `/vagrant/certs`, which is shared between hosts.
* Use `cp` from `/vagrant/` instead `mv`. <del>This allows to re-create whole cluster</del>.
* By some reason, `kubectl` installed with just downloading in some places, but in `docs/09-install-cri-workers.md` it is installed properly with `apt`.
* Add check at the end of `docs/09-install-cri-workers.md`: `vagrant@node01:~$ containerd config dump|grep -i SystemdCgroup`
* Try to add `.kubernetes.local` names to `/etc/hosts` like in the original [Kelsey's docs/03-compute-resources.md](https://github.com/kelseyhightower/kubernetes-the-hard-way/blob/master/docs/03-compute-resources.md).
* Try IPv6!

#### Probably, mistakes in the original

`/var/lib/kubernetes/pki/ca.key` have to be copied on controlplane01 and controlplane02 to avoid:

```text
Dec 11 14:28:22 controlplane02 kube-controller-manager[1399]: E1211 14:28:22.527270    1399 controllermanager.go:771] "Error starting controller" err="failed to start kubernetes.io/kubelet-serving certificate controller: error reading CA cert file \"/var/lib/kubernetes/pki/ca.crt\": open /var/lib/kubernetes/pki/ca.key: no such file or directory" controller="certificatesigningrequest-signing-controller"
Dec 11 14:28:22 controlplane02 kube-controller-manager[1399]: E1211 14:28:22.527297    1399 controllermanager.go:247] "Error starting controllers" err="failed to start kubernetes.io/kubelet-serving certificate controller: error reading CA cert file \"/var/lib/kubernetes/pki/ca.crt\": open /var/lib/kubernetes/pki/ca.key: no such file or directory"
```

## /vagrant/ directory structure

New structure at the VM guest:

```console
 $ tree -d /vagrant/
/vagrant/
├── certs    — for *.key, *.crt
├── configs  — for *.kubeconfig, *.yaml
├── shared
│   └── bin  — for the `kubectl` and other binaries
└── ubuntu
    └── vagrant
```
