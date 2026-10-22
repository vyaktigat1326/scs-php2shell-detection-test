#!/bin/sh
# Streams a tar of the OS identity files, the dpkg database entries and every file
# owned by installed php* packages. Runs inside the fixture image.
set -e
cd /
pkgs=$(dpkg-query -W -f '${db:Status-Abbrev} ${Package}\n' 'php*' | awk '$1=="ii"{print $2}')
{
  echo etc/os-release
  echo etc/debian_version
  echo var/lib/dpkg/status
  for p in $pkgs; do
    for f in /var/lib/dpkg/info/$p.*; do [ -f "$f" ] && echo "${f#/}"; done
    while read -r f; do [ -f "$f" ] && echo "${f#/}"; done < /var/lib/dpkg/info/$p.list
  done
} | sort -u > /tmp/files
tar -ch -T /tmp/files
