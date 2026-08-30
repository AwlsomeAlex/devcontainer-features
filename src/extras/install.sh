#!/usr/bin/env bash
set -euo pipefail

DEPENDENCIES=('bubblewrap' 'iptables' 'jq' 'shellcheck' 'curl' 'ca-certificates')

. /etc/os-release

DISTRO_IDS=" ${ID:-} ${ID_LIKE:-} "
case "${DISTRO_IDS}" in
*" ubuntu "*)
	DEBIAN_FRONTEND=noninteractive apt-get update
	DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends "${DEPENDENCIES[@]}"
	apt-get clean all
	rm -rf /var/lib/apt/lists/*
	;;
*" rhel "*)
	dnf install -y --setopt=install_weak_deps=False epel-release dnf-plugins-core
	crb enable
	dnf install -y --setopt=install_weak_deps=False "${DEPENDENCIES[@]}"
	dnf clean all
	rm -rf /var/cache/dnf/*
	;;
*)
	echo "[FAIL] Unsupported distribution" >&2
	exit 1
	;;
esac

SHFMT_VERSION="${SHFMT:-latest}"
if [[ "${SHFMT_VERSION}" == "latest" ]]; then
	SHFMT_VERSION="$(curl -fsSL https://api.github.com/repos/mvdan/sh/releases/latest | jq -r '.tag_name')"
fi
SHFMT_VERSION="${SHFMT_VERSION#v}"
if [[ ! "${SHFMT_VERSION}" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
	echo "[FAIL] Invalid shfmt version: ${SHFMT_VERSION}" >&2
	exit 1
fi

case "$(uname -m)" in
x86_64) SHFMT_ARCH="amd64" ;;
aarch64) SHFMT_ARCH="arm64" ;;
*)
	echo "[FAIL] Unsupported architecture for shfmt: $(uname -m)" >&2
	exit 1
	;;
esac

curl -fsSL \
	"https://github.com/mvdan/sh/releases/download/v${SHFMT_VERSION}/shfmt_v${SHFMT_VERSION}_linux_${SHFMT_ARCH}" \
	-o /usr/local/bin/shfmt
chmod 0755 /usr/local/bin/shfmt
