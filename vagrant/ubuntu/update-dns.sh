#!/bin/bash

# TODO: why do we need this change? To use our records from `/etc/hosts`?
# Then we probably should just use `getent ahosts` instead of `dig +short` in this course.
# See also: https://github.com/mmumshad/kubernetes-the-hard-way/issues/355

# Vagrant image Debian 12 Bookworm by default doesn't use `systemd-resolve`.
# So let's check if `systemd-resolve` exist:
if systemd-resolve --status >/dev/null 2>/dev/null; then
  mkdir -pv /etc/systemd/resolved.conf.d
  cat <<EOF > /etc/systemd/resolved.conf.d/dns_servers.conf
[Resolve]
# Use CZ.NIC ODVR public recursive DNS:
DNS=193.17.47.1 185.43.135.1 2001:148f:ffff::1 2001:148f:fffe::1
# FallbackDNS=127.0.0.1 ::1
Domains=~.
EOF

service systemd-resolved restart
else
  echo "No systemd-resolved found, no need to change anything"
fi
