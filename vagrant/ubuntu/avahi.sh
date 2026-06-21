#!/bin/bash

apt-get -qq update

# This package allows to lookup for .local mDNS addresses:
apt-get -y -V --no-install-recommends install libnss-mdns
# Configure the libc "GNU Name Service Switch" to use IPv6 by default for mDNS:
# > hosts:          files mdns6_minimal [NOTFOUND=return] dns
sed -i -- s/mdns4_minimal/mdns6_minimal/g /etc/nsswitch.conf

# This package will publish .local address:
apt-get -y -V --no-install-recommends install avahi-daemon
