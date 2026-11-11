#!/usr/bin/env bash
set -euo pipefail

. /etc/os-release

DEPENDENCIES=('ca-certificates' 'curl' 'tar')

DISTRO_IDS=" ${ID:-} ${ID_LIKE:-} "
case "${DISTRO_IDS}" in
*" ubuntu "*)
	DEPENDENCIES+=('xz-utils' 'libatomic1')
	DEBIAN_FRONTEND=noninteractive apt-get update
	DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends "${DEPENDENCIES[@]}"
	apt-get clean all && rm -rf /var/lib/apt/lists/*
	;;
*" rhel "*)
	DEPENDENCIES+=('xz' 'libatomic')
	dnf install -y --setopt=install_weak_deps=False epel-release dnf-plugins-core
	crb enable
	dnf install -y --setopt=install_weak_deps=False "${DEPENDENCIES[@]}"
	dnf clean all && rm -rf /var/cache/dnf/*
	;;
*)
	echo "[FAIL] Unsupported distribution: ${ID:-unknown} ${ID_LIKE:-}" >&2
	exit 1
	;;
esac

case "$(uname -m)" in
amd64 | x86_64) NODE_ARCH="x64" ;;
arm64 | aarch64) NODE_ARCH="arm64" ;;
*)
	echo "[FAIL] Unsupported architecture: $(uname -m)" >&2
	exit 1
	;;
esac

NODEJS_VERSION="${NODEJSVERSION:-latest}"
if [[ "${NODEJS_VERSION}" == "latest" ]]; then
	NODE_DIST_BASE="https://nodejs.org/dist/latest-v26.x"
else
	if [[ ! "${NODEJS_VERSION}" =~ ^v?(0|[1-9][0-9]{0,2})\.(0|[1-9][0-9]{0,2})\.(0|[1-9][0-9]{0,3})$ ]]; then
		echo "[FAIL] Invalid nodejsVersion: ${NODEJS_VERSION}. Use 'latest' or a stable semantic version." >&2
		exit 1
	fi

	NODE_MAJOR="${BASH_REMATCH[1]}"
	NODE_MINOR="${BASH_REMATCH[2]}"
	NODEJS_VERSION="${NODEJS_VERSION#v}"
	if ((NODE_MAJOR < 22 || (NODE_MAJOR == 22 && NODE_MINOR < 19))); then
		echo "[FAIL] Pi requires Node.js 22.19.0 or newer; got ${NODEJS_VERSION}." >&2
		exit 1
	fi

	NODE_DIST_BASE="https://nodejs.org/dist/v${NODEJS_VERSION}"
fi

NODE_RELEASE="$(curl -fsSL "${NODE_DIST_BASE}/SHASUMS256.txt" | awk -v suffix="-linux-${NODE_ARCH}.tar.xz" '$2 ~ /^node-v/ && substr($2, length($2) - length(suffix) + 1) == suffix { print $1, $2; exit }')"
read -r NODE_SHA NODE_ARCHIVE <<<"${NODE_RELEASE}"
if [[ -z "${NODE_SHA:-}" || -z "${NODE_ARCHIVE:-}" ]]; then
	echo "[FAIL] No Node.js ${NODEJS_VERSION} binary is available for linux-${NODE_ARCH}." >&2
	exit 1
fi

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "${TMP_DIR}"' EXIT

echo "[....] Downloading ${NODE_ARCHIVE}"
curl -fsSL "${NODE_DIST_BASE}/${NODE_ARCHIVE}" -o "${TMP_DIR}/${NODE_ARCHIVE}"
(
	cd "${TMP_DIR}"
	printf '%s  %s\n' "${NODE_SHA}" "${NODE_ARCHIVE}" | sha256sum --check -
)

tar -xJf "${TMP_DIR}/${NODE_ARCHIVE}" -C "${TMP_DIR}"
NODE_ROOT="/usr/local/lib/nodejs"
rm -rf "${NODE_ROOT}"
mv "${TMP_DIR}/${NODE_ARCHIVE%.tar.xz}" "${NODE_ROOT}"
install -d /usr/local/bin
for NODE_COMMAND in node npm npx; do
	ln -sfn "${NODE_ROOT}/bin/${NODE_COMMAND}" "/usr/local/bin/${NODE_COMMAND}"
done

NODE_VERSION="$(node --version)"
NPM_VERSION="$(npm --version)"
echo "[....] Using Node.js ${NODE_VERSION} and npm ${NPM_VERSION}"

PI_AGENT_DIR="/usr/local/share/pi"
export PI_CODING_AGENT_DIR="${PI_AGENT_DIR}"
export PATH="${PI_AGENT_DIR}/bin:/usr/local/bin:${PATH}"

echo "[....] Installing Pi using the official installer"
curl -fsSL https://pi.dev/install.sh | sh

if [[ ! -x "${PI_AGENT_DIR}/bin/pi" ]]; then
	echo "[FAIL] The Pi installer did not create ${PI_AGENT_DIR}/bin/pi." >&2
	exit 1
fi

install -d /usr/local/bin
ln -sfn "${PI_AGENT_DIR}/bin/pi" /usr/local/bin/pi
hash -r

if ! pi --version; then
	echo "[FAIL] Pi installation failed." >&2
	exit 1
fi
echo "[DONE] Pi was successfully installed!"
