#!/usr/bin/env bash
set -euo pipefail

# Capture this before sourcing /etc/os-release, which also defines VERSION.
AWSCLI_VERSION="${VERSION:-latest}"
INSTALL_SSM_PLUGIN="${INSTALLSSMPLUGIN:-false}"

if [[ "${AWSCLI_VERSION}" != "latest" && ! "${AWSCLI_VERSION}" =~ ^2\.[0-9]+\.[0-9]+$ ]]; then
	echo "[FAIL] Invalid AWS CLI v2 version '${AWSCLI_VERSION}'. Expected 'latest' or a version such as '2.0.30'." >&2
	exit 1
fi

case "${INSTALL_SSM_PLUGIN}" in
	true|false) ;;
	*)
		echo "[FAIL] Invalid installSSMPlugin value '${INSTALL_SSM_PLUGIN}'. Expected 'true' or 'false'." >&2
		exit 1
		;;
esac

case "$(uname -m)" in
	x86_64)
		AWSCLI_ARCH="x86_64"
		SSM_PLUGIN_RPM_ARCH="linux_64bit"
		SSM_PLUGIN_DEB_ARCH="ubuntu_64bit"
		;;
	aarch64)
		AWSCLI_ARCH="aarch64"
		SSM_PLUGIN_RPM_ARCH="linux_arm64"
		SSM_PLUGIN_DEB_ARCH="ubuntu_arm64"
		;;
	*)
		echo "[FAIL] Unsupported architecture for AWS CLI and Session Manager plugin: $(uname -m)" >&2
		exit 1
		;;
esac

DEPENDENCIES=('ca-certificates' 'curl' 'unzip')

. /etc/os-release

DISTRO_IDS=" ${ID:-} ${ID_LIKE:-} "
case "${DISTRO_IDS}" in
*" ubuntu "*)
	DEBIAN_FRONTEND=noninteractive apt-get update
	DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends "${DEPENDENCIES[@]}"
	PACKAGE_MANAGER="apt"
	;;
*" rhel "*)
	dnf install -y --setopt=install_weak_deps=False epel-release dnf-plugins-core
	crb enable
	dnf install -y --setopt=install_weak_deps=False "${DEPENDENCIES[@]}"
	PACKAGE_MANAGER="dnf"
	;;
*)
	echo "[FAIL] Unsupported distribution: ${ID:-unknown} (ID_LIKE=${ID_LIKE:-none})" >&2
	exit 1
	;;
esac

TEMP_DIR="$(mktemp -d)"
trap 'rm -rf "${TEMP_DIR}"' EXIT

AWSCLI_ASSET="awscli-exe-linux-${AWSCLI_ARCH}"
if [[ "${AWSCLI_VERSION}" != "latest" ]]; then
	AWSCLI_ASSET+="-${AWSCLI_VERSION}"
fi
AWSCLI_ASSET+=".zip"

curl -fsSL "https://awscli.amazonaws.com/${AWSCLI_ASSET}" -o "${TEMP_DIR}/awscliv2.zip"
unzip -q "${TEMP_DIR}/awscliv2.zip" -d "${TEMP_DIR}"
"${TEMP_DIR}/aws/install" --install-dir /usr/local/aws-cli --bin-dir /usr/local/bin

if ! command -v aws >/dev/null 2>&1; then
	echo "[FAIL] AWS CLI installation did not provide the aws command." >&2
	exit 1
fi

AWSCLI_INSTALLED_VERSION="$(aws --version 2>&1)"
if [[ "${AWSCLI_VERSION}" != "latest" && "${AWSCLI_INSTALLED_VERSION}" != aws-cli/"${AWSCLI_VERSION}"* ]]; then
	echo "[FAIL] Requested AWS CLI ${AWSCLI_VERSION}, but installed '${AWSCLI_INSTALLED_VERSION}'." >&2
	exit 1
fi

if [[ "${INSTALL_SSM_PLUGIN}" == "true" ]]; then
	if [[ "${PACKAGE_MANAGER}" == "apt" ]]; then
		SSM_PLUGIN_URL="https://s3.amazonaws.com/session-manager-downloads/plugin/latest/${SSM_PLUGIN_DEB_ARCH}/session-manager-plugin.deb"
		curl -fsSL "${SSM_PLUGIN_URL}" -o "${TEMP_DIR}/session-manager-plugin.deb"
		dpkg -i "${TEMP_DIR}/session-manager-plugin.deb"
	else
		SSM_PLUGIN_URL="https://s3.amazonaws.com/session-manager-downloads/plugin/latest/${SSM_PLUGIN_RPM_ARCH}/session-manager-plugin.rpm"
		dnf install -y --setopt=install_weak_deps=False "${SSM_PLUGIN_URL}"
	fi

	if ! command -v session-manager-plugin >/dev/null 2>&1; then
		echo "[FAIL] Session Manager plugin installation did not provide session-manager-plugin." >&2
		exit 1
	fi
	session-manager-plugin --version
fi

if [[ "${PACKAGE_MANAGER}" == "apt" ]]; then
	apt-get clean all
	rm -rf /var/lib/apt/lists/*
else
	dnf clean all
	rm -rf /var/cache/dnf/*
fi

echo "[DONE] Installed ${AWSCLI_INSTALLED_VERSION}."
