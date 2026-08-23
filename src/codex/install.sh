#!/usr/bin/env bash
set -euo pipefail

CODEX_VERSION="${VERSION:-latest}"

. /etc/os-release

DEPENDENCIES=('ca-certificates' 'curl' 'zstd')

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

# Codex CLI is only available for linux/amd64 and linux/arm64
ARCH="$(uname -m)"
case "${ARCH}" in
x86_64)
	CODEX_ARCH="x86_64"
	;;
aarch64 | arm64)
	CODEX_ARCH="aarch64"
	;;
*)
	echo "[FAIL] Unsupported architecture: ${ARCH}" >&2
	exit 1
	;;
esac

TARGET="${CODEX_ARCH}-unknown-linux-musl"
GH_ASSET="codex-${TARGET}.zst"
BINARY="codex-${TARGET}"

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "${TMP_DIR}"' EXIT

echo "[....] Downloading Codex CLI from GitHub..."
if [[ -z ${CODEX_VERSION:-} || "${CODEX_VERSION}" == "latest" ]]; then
	DOWNLOAD_URL="https://github.com/openai/codex/releases/latest/download/${GH_ASSET}"
else
	DOWNLOAD_URL="https://github.com/openai/codex/releases/download/rust-v${CODEX_VERSION}/${GH_ASSET}"
fi
echo $DOWNLOAD_URL
curl -fsSL "${DOWNLOAD_URL}" -o "${TMP_DIR}/${GH_ASSET}"

echo "[....] Installing Codex CLI"
# OpenAI publishes the binary compressed with ZSTD directly to GitHub
zstd -d \
	"${TMP_DIR}/${GH_ASSET}" \
	-o "${TMP_DIR}/${BINARY}"
install -m 0755 \
	"${TMP_DIR}/${BINARY}" \
	/usr/local/bin/codex

if ! codex --version; then
	echo "[FAIL] Codex CLI installation failed." >&2
	exit 1
fi
echo "[DONE] Codex CLI was successfully installed!"
