#!/usr/bin/env bash
# Verifies the fixture binaries without running them: checks SHA-256 sums and the
# version string compiled into each binary by the PHP build.
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"

for case_dir in "$root"/cases/*/; do
  expected="$(cat "$case_dir/.php-version")"
  (cd "$case_dir" && shasum -a 256 -c SHA256SUMS >/dev/null)
  for bin in runtime/usr/local/bin/php runtime/usr/local/sbin/php-fpm; do
    embedded="$(LC_ALL=C grep -a -m1 -oE 'X-Powered-By: PHP/[0-9.]+' "$case_dir/$bin" | head -1 | sed 's#.*/##')"
    if [[ "$embedded" != "$expected" ]]; then
      echo "FAIL $case_dir$bin: embedded=$embedded expected=$expected" >&2
      exit 1
    fi
    echo "OK   $(basename "$case_dir")/$bin -> PHP $embedded"
  done
done
