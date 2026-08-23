#!/usr/bin/env bash
set -euo pipefail

CODEX_VERSION="${VERSION:-latest}"

. /etc/os-release

DEPENDENCIES=('ca-certificates' 'curl')

# Primarily targeting Ubuntu and RHEL (Rocky) for now
DISTRO_IDS=" ${ID:-} ${ID_LIKE:-} "
case "${DISTRO_IDS}" in
*" ubuntu "*)
	DEBIAN_FRONTEND=noninteractive apt-get update
	DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends "${DEPENDENCIES[@]}"
	;;
*" rhel "*)
	dnf install -y --setopt=install_weak_deps=False "${DEPENDENCIES[@]}"
	;;
*)
	echo "[FAIL] Unsupported distribution" >&2
	exit 1
	;;
esac

echo "[....] Installing Codex CLI using the official installer"
curl -fsSL https://chatgpt.com/codex/install.sh |
	CODEX_NON_INTERACTIVE=true \
		CODEX_INSTALL_DIR=/usr/local/bin \
		CODEX_HOME=/usr/local/share/codex \
		sh -s -- --release "${CODEX_VERSION}"

if ! codex --version; then
	echo "[FAIL] Codex CLI installation failed." >&2
	exit 1
fi
echo "[DONE] Codex CLI was successfully installed!"
