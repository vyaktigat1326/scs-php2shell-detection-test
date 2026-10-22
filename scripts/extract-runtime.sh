#!/usr/bin/env bash
# Reproducibly extracts genuine PHP runtime binaries from the official php images,
# pinned by digest. The image is only used as a binary source: nothing is scanned
# and the binaries are not executed.
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"

extract() {
  local version="$1" image="$2" dest="$root/cases/$3/runtime"
  local cid
  docker pull --platform linux/arm64 "$image" >/dev/null
  cid="$(docker create --platform linux/arm64 "$image")"
  mkdir -p "$dest/usr/local/bin" "$dest/usr/local/sbin"
  docker cp -q "$cid:/usr/local/bin/php" "$dest/usr/local/bin/php"
  docker cp -q "$cid:/usr/local/sbin/php-fpm" "$dest/usr/local/sbin/php-fpm"
  docker rm "$cid" >/dev/null
  echo "$version extracted from $image"
}

extract 8.4.26 "php@sha256:f5431b57bda75455d5271967cc6b67df8f0d0b943832756e0c78eccdc98767dd" vulnerable-php-8.4.26
extract 8.4.27 "php@sha256:e2d8e787dc775bdbd9d7e0c5e8f2f9ddb41ce5977c8bbaf99a2ba2e7d90fd8ae" patched-php-8.4.27
