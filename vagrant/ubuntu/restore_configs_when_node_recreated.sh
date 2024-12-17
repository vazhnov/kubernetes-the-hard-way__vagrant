#!/usr/bin/env bash
set -o nounset
set -o errexit
set -o pipefail
shopt -s dotglob
shopt -s failglob  # if the option is set, and no matches are found, an error message is printed and the command is not executed.

# This script is useful when by some reason your VM machines were destroyed, but your files are stored in the shared Vagrant volume `/vagrant`.
# It is very useful for me because my whole VMs setup is dynamic: I store disks in ZRAM.
#
# Script expects such structure at the VM guest:
# ```
#  $ tree -d /vagrant/
# /vagrant/
# ├── certs    — for *.key, *.crt
# ├── configs  — for *.kubeconfig, *.yaml
# ├── shared   — for the `kubectl` binary
# └── ubuntu
#     └── vagrant
# ```


copy_if_needed(){
  # Copy only when the source file exist and target file not exist
  # It helps to restore files which were created previously and spread them to empty node, but not rewrite anything.
  local src="$1"
  local target="$2"
  if [ -e "$src" ] && [ ! -e "$target" ]; then
    cp -pv "$src" "$target"
  else
    echo "Skipped: $src → $target"
  fi
}

mkdir -p /var/lib/kubernetes/pki

copy_if_needed /vagrant/shared/kubectl /usr/local/bin/kubectl
copy_if_needed /vagrant/certs/ca.crt /var/lib/kubernetes/pki/ca.crt

if [[ "$(hostname)" =~ controlplane0[[:digit:]] ]]; then
  # From `docs/06-data-encryption-keys.md`:
  copy_if_needed /vagrant/configs/encryption-config.yaml /var/lib/kubernetes/encryption-config.yaml
  # From `docs/07-bootstrapping-etcd.md`:
  mkdir -p /etc/etcd /var/lib/etcd
  copy_if_needed /vagrant/certs/etcd-server.key /etc/etcd/etcd-server.key
  copy_if_needed /vagrant/certs/etcd-server.crt /etc/etcd/etcd-server.crt
  ln -s -f -v /var/lib/kubernetes/pki/ca.crt /etc/etcd/ca.crt
  chown -R root:root /etc/etcd
  chmod 600 -- /etc/etcd/*
  copy_if_needed /vagrant/shared/etcd    /usr/local/bin/etcd
  copy_if_needed /vagrant/shared/etcdctl /usr/local/bin/etcdctl
  copy_if_needed /vagrant/shared/etcdutl /usr/local/bin/etcdutl

  # From `docs/08-bootstrapping-kubernetes-controllers.md`:
  copy_if_needed /vagrant/shared/kube-apiserver          /usr/local/bin/kube-apiserver
  copy_if_needed /vagrant/shared/kube-controller-manager /usr/local/bin/kube-controller-manager
  copy_if_needed /vagrant/shared/kube-scheduler          /usr/local/bin/kube-scheduler
  for c in kube-apiserver service-account apiserver-kubelet-client etcd-server kube-scheduler kube-controller-manager
  do
    copy_if_needed "/vagrant/certs/$c.crt" "/var/lib/kubernetes/pki/$c.crt"
    copy_if_needed "/vagrant/certs/$c.key" "/var/lib/kubernetes/pki/$c.key"
  done
  copy_if_needed /vagrant/configs/kube-controller-manager.kubeconfig /var/lib/kubernetes/kube-controller-manager.kubeconfig
  copy_if_needed /vagrant/configs/kube-scheduler.kubeconfig /var/lib/kubernetes/kube-scheduler.kubeconfig

  # Additionally from me:
  copy_if_needed /vagrant/certs/ca.key /var/lib/kubernetes/pki/ca.key
fi

if [[ "$(hostname)" =~ node0[[:digit:]] ]]; then
  # From `docs/10-bootstrapping-kubernetes-workers.md`:
  copy_if_needed /vagrant/shared/bin/kubelet    /usr/local/bin/kubelet
  copy_if_needed /vagrant/shared/bin/kube-proxy /usr/local/bin/kube-proxy
  copy_if_needed /vagrant/certs/kube-proxy.crt  /var/lib/kubernetes/pki/kube-proxy.crt
  copy_if_needed /vagrant/certs/kube-proxy.key  /var/lib/kubernetes/pki/kube-proxy.key
fi

# From `docs/07-bootstrapping-etcd.md`:
chown -R root:root /var/lib/kubernetes/pki
chmod 600 -- /var/lib/kubernetes/pki/*

chown -R root:root -- /usr/local/bin/*

set +o errexit  # temporary for `loadbalancer` node, which doesn't have any file in `/var/lib/kubernetes/*.kubeconfig`
chmod 600 -- /var/lib/kubernetes/*.kubeconfig
exit 0
