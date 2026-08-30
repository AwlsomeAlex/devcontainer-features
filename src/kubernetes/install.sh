#!/usr/bin/env bash
set -euo pipefail

KUBECTL_VERSION="${KUBECTLVERSION:-latest}"
HELM_VERSION="${HELMVERSION:-latest}"
K9S_VERSION="${K9SVERSION:-latest}"
KIND_VERSION="${KINDVERSION:-latest}"
MINIKUBE_VERSION="${MINIKUBEVERSION:-latest}"
DEPENDENCIES=('ca-certificates' 'curl' 'jq' 'tar' 'gzip')

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

resolve_github_version() {
	local repository="$1"
	curl -fsSL "https://api.github.com/repos/${repository}/releases/latest" | jq -r '.tag_name'
}

normalize_version() {
	local version="${1#v}"
	if [[ ! "${version}" =~ ^[0-9]+\.[0-9]+\.[0-9]+([.-][0-9A-Za-z.-]+)?$ ]]; then
		echo "[FAIL] Invalid version: ${1}" >&2
		exit 1
	fi
	echo "${version}"
}

if [[ "${KUBECTL_VERSION}" == "latest" ]]; then
	KUBECTL_VERSION="$(curl -fsSL https://dl.k8s.io/release/stable.txt)"
fi
KUBECTL_VERSION="$(normalize_version "${KUBECTL_VERSION}")"

if [[ "${HELM_VERSION}" == "latest" ]]; then
	HELM_VERSION="$(resolve_github_version helm/helm)"
fi
HELM_VERSION="$(normalize_version "${HELM_VERSION}")"

if [[ "${K9S_VERSION}" == "latest" ]]; then
	K9S_VERSION="$(resolve_github_version derailed/k9s)"
fi
K9S_VERSION="$(normalize_version "${K9S_VERSION}")"

if [[ "${KIND_VERSION}" == "latest" ]]; then
	KIND_VERSION="$(resolve_github_version kubernetes-sigs/kind)"
fi
KIND_VERSION="$(normalize_version "${KIND_VERSION}")"

if [[ "${MINIKUBE_VERSION}" == "latest" ]]; then
	MINIKUBE_VERSION="$(resolve_github_version kubernetes/minikube)"
fi
MINIKUBE_VERSION="$(normalize_version "${MINIKUBE_VERSION}")"

case "$(uname -m)" in
	x86_64)
	ARCH="amd64"
	;;
	aarch64)
	ARCH="arm64"
	;;
	*)
		echo "[FAIL] Unsupported architecture for Kubernetes tools: $(uname -m)" >&2
		exit 1
		;;
esac

TEMP_DIR="$(mktemp -d)"
trap 'rm -rf "${TEMP_DIR}"' EXIT

# kubectl is distributed as a standalone binary by Kubernetes.
curl -fsSL "https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/linux/${ARCH}/kubectl" \
	-o /usr/local/bin/kubectl
chmod 0755 /usr/local/bin/kubectl

# Helm is distributed as a platform tarball.
HELM_ASSET="helm-v${HELM_VERSION}-linux-${ARCH}.tar.gz"
curl -fsSL "https://get.helm.sh/${HELM_ASSET}" -o "${TEMP_DIR}/${HELM_ASSET}"
curl -fsSL "https://get.helm.sh/${HELM_ASSET}.sha256sum" -o "${TEMP_DIR}/${HELM_ASSET}.sha256sum"
HELM_CHECKSUM="$(grep -Eo '[[:xdigit:]]{64}' "${TEMP_DIR}/${HELM_ASSET}.sha256sum" | head -n 1)"
if [[ -z "${HELM_CHECKSUM}" ]]; then
	echo "[FAIL] No checksum found for ${HELM_ASSET}" >&2
	exit 1
fi
echo "${HELM_CHECKSUM}  ${TEMP_DIR}/${HELM_ASSET}" | sha256sum --check --status
tar -xzf "${TEMP_DIR}/${HELM_ASSET}" -C "${TEMP_DIR}"
install -m 0755 "${TEMP_DIR}/linux-${ARCH}/helm" /usr/local/bin/helm

# k9s is distributed as a platform tarball.
K9S_ASSET="k9s_Linux_${ARCH}.tar.gz"
K9S_URL="https://github.com/derailed/k9s/releases/download/v${K9S_VERSION}"
curl -fsSL "${K9S_URL}/${K9S_ASSET}" -o "${TEMP_DIR}/${K9S_ASSET}"
curl -fsSL "${K9S_URL}/checksums.sha256" -o "${TEMP_DIR}/k9s-checksums.sha256"
K9S_CHECKSUM="$(awk -v asset="${K9S_ASSET}" '$2 == asset || $2 == "./" asset { print $1; exit }' "${TEMP_DIR}/k9s-checksums.sha256")"
if [[ -z "${K9S_CHECKSUM}" ]]; then
	echo "[FAIL] No checksum found for ${K9S_ASSET}" >&2
	exit 1
fi
echo "${K9S_CHECKSUM}  ${TEMP_DIR}/${K9S_ASSET}" | sha256sum --check --status
tar -xzf "${TEMP_DIR}/${K9S_ASSET}" -C "${TEMP_DIR}"
install -m 0755 "${TEMP_DIR}/k9s" /usr/local/bin/k9s

# kind publishes versioned Linux binaries from kind.sigs.k8s.io.
KIND_ASSET="kind-linux-${ARCH}"
curl -fsSL "https://kind.sigs.k8s.io/dl/v${KIND_VERSION}/${KIND_ASSET}" \
	-o /usr/local/bin/kind
chmod 0755 /usr/local/bin/kind

# Minikube publishes versioned Linux binaries from Google Cloud Storage.
MINIKUBE_ASSET="minikube-linux-${ARCH}"
curl -fsSL "https://storage.googleapis.com/minikube/releases/v${MINIKUBE_VERSION}/${MINIKUBE_ASSET}" \
	-o /usr/local/bin/minikube
chmod 0755 /usr/local/bin/minikube
