#!/bin/bash

# Disable all auto-fetch activity.

# Some services exist in Ubuntu only, so ignore such errors in Debian:
# > Failed to disable unit: Unit file motd-news.timer does not exist.
# > Failed to disable unit: Unit file ubuntu-advantage.service does not exist.
systemctl --quiet disable motd-news.timer ubuntu-advantage.service apt-daily.timer apt-daily.service unattended-upgrades.service
systemctl --quiet stop apt-daily.timer unattended-upgrades.service
