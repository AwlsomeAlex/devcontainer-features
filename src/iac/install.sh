#!/usr/bin/env bash
set -euo pipefail

OPENTOFU_VERSION="${OPENTOFUVERSION:-latest}"
TERRAGRUNT_VERSION="${TERRAGRUNTVERSION:-latest}"
DEPENDENCIES=('ca-certificates' 'curl' 'jq' 'unzip')

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

if [[ "${OPENTOFU_VERSION}" == "latest" ]]; then
	OPENTOFU_VERSION="$(curl -fsSL https://api.github.com/repos/opentofu/opentofu/releases/latest | jq -r '.tag_name')"
fi
OPENTOFU_VERSION="${OPENTOFU_VERSION#v}"
if [[ ! "${OPENTOFU_VERSION}" =~ ^[0-9]+\.[0-9]+\.[0-9]+([.-][0-9A-Za-z.-]+)?$ ]]; then
	echo "[FAIL] Invalid OpenTofu version: ${OPENTOFU_VERSION}" >&2
	exit 1
fi

if [[ "${TERRAGRUNT_VERSION}" == "latest" ]]; then
	TERRAGRUNT_VERSION="$(curl -fsSL https://api.github.com/repos/gruntwork-io/terragrunt/releases/latest | jq -r '.tag_name')"
fi
TERRAGRUNT_VERSION="${TERRAGRUNT_VERSION#v}"
if [[ ! "${TERRAGRUNT_VERSION}" =~ ^[0-9]+\.[0-9]+\.[0-9]+([.-][0-9A-Za-z.-]+)?$ ]]; then
	echo "[FAIL] Invalid Terragrunt version: ${TERRAGRUNT_VERSION}" >&2
	exit 1
fi

case "$(uname -m)" in
	x86_64)
	OPENTOFU_ARCH="amd64"
	TERRAGRUNT_ARCH="amd64"
	;;
	aarch64)
	OPENTOFU_ARCH="arm64"
	TERRAGRUNT_ARCH="arm64"
	;;
	*)
		echo "[FAIL] Unsupported architecture for IAC tools: $(uname -m)" >&2
		exit 1
		;;
esac

TEMP_DIR="$(mktemp -d)"
trap 'rm -rf "${TEMP_DIR}"' EXIT

TOFU_ASSET="tofu_${OPENTOFU_VERSION}_linux_${OPENTOFU_ARCH}.zip"
TOFU_URL="https://github.com/opentofu/opentofu/releases/download/v${OPENTOFU_VERSION}"
curl -fsSL "${TOFU_URL}/${TOFU_ASSET}" -o "${TEMP_DIR}/${TOFU_ASSET}"
curl -fsSL "${TOFU_URL}/tofu_${OPENTOFU_VERSION}_SHA256SUMS" -o "${TEMP_DIR}/tofu-SHA256SUMS"

EXPECTED_CHECKSUM="$(awk -v asset="${TOFU_ASSET}" '$2 == asset || $2 == "./" asset { print $1; exit }' "${TEMP_DIR}/tofu-SHA256SUMS")"
if [[ -z "${EXPECTED_CHECKSUM}" ]]; then
	echo "[FAIL] No checksum found for ${TOFU_ASSET}" >&2
	exit 1
fi
echo "${EXPECTED_CHECKSUM}  ${TEMP_DIR}/${TOFU_ASSET}" | sha256sum --check --status
unzip -q "${TEMP_DIR}/${TOFU_ASSET}" -d "${TEMP_DIR}"
install -m 0755 "${TEMP_DIR}/tofu" /usr/local/bin/tofu

TERRAGRUNT_ASSET="terragrunt_linux_${TERRAGRUNT_ARCH}"
TERRAGRUNT_URL="https://github.com/gruntwork-io/terragrunt/releases/download/v${TERRAGRUNT_VERSION}"
curl -fsSL "${TERRAGRUNT_URL}/${TERRAGRUNT_ASSET}" -o "${TEMP_DIR}/${TERRAGRUNT_ASSET}"
curl -fsSL "${TERRAGRUNT_URL}/SHA256SUMS" -o "${TEMP_DIR}/terragrunt-SHA256SUMS"

EXPECTED_CHECKSUM="$(awk -v asset="${TERRAGRUNT_ASSET}" '$2 == asset || $2 == "./" asset { print $1; exit }' "${TEMP_DIR}/terragrunt-SHA256SUMS")"
if [[ -z "${EXPECTED_CHECKSUM}" ]]; then
	echo "[FAIL] No checksum found for ${TERRAGRUNT_ASSET}" >&2
	exit 1
fi
echo "${EXPECTED_CHECKSUM}  ${TEMP_DIR}/${TERRAGRUNT_ASSET}" | sha256sum --check --status
install -m 0755 "${TEMP_DIR}/${TERRAGRUNT_ASSET}" /usr/local/bin/terragrunt
