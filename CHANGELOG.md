## 2024-12

Rewriting parts which I don't like.

**Work in progress**.

It is assumed that you're working on GNU/Linux or similar environment and you're confident in it.

It is assumed that guest VMs could be destroyed and then recreated from scratch, only the shared Vagrant volume `/vagrant` survives.

* Use Debian images instead of Ubuntu — less memory consumption, less services to disable, no Snap.
* Store all certs in `/vagrant/certs`, which is shared between hosts.
* Use current directory in `cert_verify.sh` instead of hardcoded home directory.
* Use `getent ahosts example.com | cut -d' ' -f1` everywhere because it follows `/etc/nsswitch.conf` rules (reads `/etc/hosts`, mDNS, etc.), instead of `dig +short example.org`.

## Notes

### If cluster was recreated (disks were destroyed)

* Script `ubuntu/restore_configs_when_node_recreated.sh` will copy most of files which were stored in the shared Vagrant volume `/vagrant`
* Init-files `/etc/systemd/system/etcd.service` have to be recreated, steps are in [07-bootstrapping-etcd.md](docs/07-bootstrapping-etcd.md).
* `etcd` service have to be enabled and started.

## TODO

* Remove US style capitalization, use [Wikipedia:Naming conventions (capitalization)](https://en.wikipedia.org/wiki/Wikipedia:Naming_conventions_(capitalization)) instead.
* Split `vagrant/ubuntu/ssh.sh` into smaller files?
* Add an example of command like `openssl x509 -noout -text -in kube-apiserver.crt`.
* Add `.yaml` to all `.kubeconfig` filenames.
* Probably no need to create new SSH key on `controlplane01`, just use `ssh -A` to use exist SSH key with agent forwarding.
* No need in `tmux`, just open tabs in terminal.
* Check if commands `kubectl config use-context default --kubeconfig=xxx.kubeconfig` are needed in `docs/05-kubernetes-configuration-files.md` (probably not).
* Use `cp` from `/vagrant/` instead `mv`. This allows to re-create whole cluster.
