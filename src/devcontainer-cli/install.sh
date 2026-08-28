#!/usr/bin/env bash
set -euo pipefail

CLI_VERSION="${VERSION:-0.88.0}"

DEPENDENCIES=('ca-certificates' 'curl')

. /etc/os-release

DISTRO_IDS=" ${ID:-} ${ID_LIKE:-} "
case "${DISTRO_IDS}" in
*" ubuntu "*)
	DEBIAN_FRONTEND=noninteractive apt-get update
	DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends "${DEPENDENCIES[@]}" xz-utils
	apt-get clean all
	rm -rf /var/lib/apt/lists/*
	;;
*" rhel "*)
	dnf install -y --setopt=install_weak_deps=False "${DEPENDENCIES[@]}" xz
	dnf clean all
	rm -rf /var/cache/dnf/*
	;;
*)
	echo "[FAIL] Unsupported distribution" >&2
	exit 1
	;;
esac

PREFIX="/usr/local"
INSTALL_SCRIPT="/tmp/devcontainer-cli-install.sh"

curl -fsSL \
	https://raw.githubusercontent.com/devcontainers/cli/main/scripts/install.sh \
	-o "${INSTALL_SCRIPT}"
chmod +x "${INSTALL_SCRIPT}"

sh "${INSTALL_SCRIPT}" \
	--version "${CLI_VERSION}" \
	--prefix "${PREFIX}"

rm -f "${INSTALL_SCRIPT}"
