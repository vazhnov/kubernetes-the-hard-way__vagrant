## 2024-12

Rewriting parts which I don't like.

Work in progress.

* It is assumed that you're working on GNU/Linux or similar environment.
* Use Debian images instead of Ubuntu — less memory consumption, less services to disable, no Snap.
* Store all certs in `/vagrant/certs`, which is shared between hosts.
* Use current directory in `cert_verify.sh` instead of hardcoded home directory.
* Use `getent ahosts example.com | cut -d' ' -f1` everywhere because it follows `/etc/nsswitch.conf` rules (reads `/etc/hosts`, mDNS, etc.), instead of `dig +short example.org`.

TODO:

* Remove US style capitalization, use [Wikipedia:Naming conventions (capitalization)](https://en.wikipedia.org/wiki/Wikipedia:Naming_conventions_(capitalization)) instead.
* Split `vagrant/ubuntu/ssh.sh` into smaller files?
* Add an example of command like `openssl x509 -noout -text -in kube-apiserver.crt`.
* Add `.yaml` to all `.kubeconfig` filenames.
* Probably no need to create new SSH key on `controlplane01`, just use `ssh -A` to use exist SSH key with agent forwarding.
* No need in `tmux`, just open tabs in terminal.
