#!/usr/bin/env bash
set -euo pipefail

LAZYGIT_VERSION="${VERSION:-latest}"

. /etc/os-release

DEPENDENCIES=('ca-certificates' 'curl' 'tar' 'git' 'git-lfs' 'gnupg2' 'gpg')

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

# LazyGit releases are available for linux/amd64 and linux/arm64
ARCH="$(uname -m)"
case "${ARCH}" in
amd64 | x86_64)
	LAZYGIT_ARCH="x86_64"
	;;
arm64 | aarch64)
	LAZYGIT_ARCH="arm64"
	;;
*)
	echo "[FAIL] Unsupported architecture: ${ARCH}" >&2
	exit 1
	;;
esac

if [[ "${LAZYGIT_VERSION}" == "latest" ]]; then
	LATEST_RELEASE_URL="$(
		curl -fsSL -o /dev/null -w '%{url_effective}' \
			https://github.com/jesseduffield/lazygit/releases/latest
	)"
	LATEST_TAG="${LATEST_RELEASE_URL##*/}"
	LAZYGIT_VERSION="${LATEST_TAG#v}"
fi

GH_ASSET="lazygit_${LAZYGIT_VERSION}_linux_${LAZYGIT_ARCH}.tar.gz"

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "${TMP_DIR}"' EXIT

echo "[....] Downloading LazyGit from GitHub..."
DOWNLOAD_URL="https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/${GH_ASSET}"
echo "${DOWNLOAD_URL}"
curl -fsSL "${DOWNLOAD_URL}" -o "${TMP_DIR}/${GH_ASSET}"

echo "[....] Installing LazyGit"
tar -xzf "${TMP_DIR}/${GH_ASSET}" -C "${TMP_DIR}"
install -m 0755 \
	"${TMP_DIR}/lazygit" \
	/usr/local/bin/lazygit

if ! lazygit --version; then
	echo "[FAIL] LazyGit installation failed." >&2
	exit 1
fi
echo "[DONE] LazyGit was successfully installed!"
