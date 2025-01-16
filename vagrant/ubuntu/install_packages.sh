#!/bin/bash

# TODO: probably we don't need this part at all:
if [ "$(hostname)" = "controlplane01" ]
then
    apt-get -qq update
    apt-get install -y -V sshpass
fi

