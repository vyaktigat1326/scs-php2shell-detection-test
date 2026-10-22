# PHP2Shell artifact fixtures for SCS artifact scanning (Billy)

Four directory artifacts for `billy generate --artifact-path <dir>`. Billy scans a
directory with its filesystem path (`fs`). These are **not** container images or
Docker archives. Don't tar them: Billy routes `.tar`/`.tar.gz` to its Docker-archive
(container) path.

| Artifact path | What it is | Source | Expected PHP2Shell result |
|---|---|---|---|
| `debian13-php8.4.24-vulnerable/rootfs` | Debian 13.7 OS identity + dpkg DB + every file of the installed `php8.4-*` packages (8.4.24-1~deb13u1) | `apt-get install php8.4-fpm=8.4.24-1~deb13u1 …` on `debian:trixie` | **CVE-2026-109618 + CVE-2026-109619**, CRITICAL, on `php8.4-{cli,common,fpm,opcache,readline}`, fixed `8.4.27-1~deb13u1` |
| `debian13-php8.4.27-patched/rootfs` | same, 8.4.27-1~deb13u1 | same | none (other Debian CVEs still reported) |
| `standalone-php8.4.26-vulnerable/runtime` | `php`, `php-fpm`, `php-config`, `phpize`, `php_version.h`, sample configs from a source-built PHP 8.4.26 | official `php@sha256:f5431b57bda75455d5271967cc6b67df8f0d0b943832756e0c78eccdc98767dd` (8.4.26-fpm, linux/arm64) | none: **unsupported**, the SBOM has 0 components |
| `standalone-php8.4.27-patched/runtime` | same for 8.4.27 | `php@sha256:e2d8e787dc775bdbd9d7e0c5e8f2f9ddb41ce5977c8bbaf99a2ba2e7d90fd8ae` | none (0 components) |

## Metadata preserved

- **Debian:**
  - `etc/os-release` and `etc/debian_version` (`13.7`): Trivy's Debian analyzer requires `etc/debian_version` at the artifact root.
  - `var/lib/dpkg/status`: the full dpkg DB.
  - `var/lib/dpkg/info/php*.{list,md5sums,…}`.
  - The package files themselves, including `usr/bin/php8.4` and `usr/sbin/php-fpm8.4`.
- **Standalone:** PHP's own version records.
  - `X-Powered-By: PHP/<ver>` compiled into `php` and `php-fpm`.
  - `#define PHP_VERSION "<ver>"` in `usr/local/include/php/main/php_version.h`.
  - `version="<ver>"` in `php-config`.
  - There is no package-manager metadata, because none exists for a source-built runtime.

`SHA256SUMS` in each artifact covers every file. Verify with:

```bash
cd <artifact> && shasum -a 256 -c SHA256SUMS
```

## Regenerate

Each command needs Docker. Images are pinned by digest, and the Debian fixtures come from local
`scs-php2shell-fixture:deb13-php<ver>` builds (`apt-get install … =<ver>` on
`debian:trixie`). Debian packages are exported by a script that reads the dpkg file
lists. Nothing is executed apart from `tar`, `dpkg-query` and `sh`.
