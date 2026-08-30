#!/usr/bin/env bash
set -euo pipefail

. /etc/os-release

DEPENDENCIES=('ca-certificates' 'curl' 'jq' 'ripgrep' 'sudo' 'git' 'git-lfs')
LOCALE="en_US.UTF-8"

DEFAULT_SHELL="/bin/bash"
if [[ "${INSTALLZSH:-true}" == "true" ]]; then
	DEPENDENCIES+=('zsh')
	DEFAULT_SHELL="/bin/zsh"
fi

# Primarily targeting Ubuntu and RHEL (Rocky) for now
DISTRO_IDS=" ${ID:-} ${ID_LIKE:-} "
case "${DISTRO_IDS}" in
*" ubuntu "*)
	DEBIAN_FRONTEND=noninteractive apt-get update
	DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends "${DEPENDENCIES[@]}" openssh-client language-pack-en xz-utils
	apt-get clean all && rm -rf /var/lib/apt/lists/*
	update-locale LANG="${LOCALE}" LC_ALL="${LOCALE}"
	;;
*" rhel "*)
	dnf install -y --setopt=install_weak_deps=False epel-release dnf-plugins-core
	crb enable
	dnf install -y --setopt=install_weak_deps=False "${DEPENDENCIES[@]}" openssh-clients glibc-langpack-en xz
	dnf clean all && rm -rf /var/cache/dnf/*
	cat >/etc/locale.conf <<EOF
LANG=${LOCALE}
LC_ALL=${LOCALE}
EOF
	;;
*)
	echo "[FAIL] Unsupported distribution" >&2
	exit 1
	;;
esac

cat >/etc/profile.d/locale.sh <<EOF
export LANG=${LOCALE}
export LC_ALL=${LOCALE}
EOF
chmod 0644 /etc/profile.d/locale.sh
export LANG="${LOCALE}"
export LC_ALL="${LOCALE}"

USERNAME="${USERNAME:-vscode}"
USERUID="${USERUID:-1000}"
USERGID="${USERGID:-1000}"

if [[ ! "${USERNAME}" =~ ^[a-z_][a-z0-9_-]*$ || "${USERNAME}" == "root" ]]; then
	echo "[FAIL] Invalid non-root username: ${USERNAME}" >&2
	exit 1
fi
if [[ ! "${USERUID}" =~ ^[0-9]+$ || ! "${USERGID}" =~ ^[0-9]+$ ]]; then
	echo "[FAIL] USERUID and USERGID must be numeric." >&2
	exit 1
fi

# Configure the requested user. If the requested UID is already occupied,
# adopt that user (for example Ubuntu's default 1000:1000 user). Otherwise,
# create a new user. Conflicting IDs are rejected instead of changing
# unrelated accounts or migrating arbitrary filesystem ownership.
if id -u "${USERNAME}" >/dev/null 2>&1; then
	USER_EXISTS=true
else
	EXISTING_USER="$(getent passwd "${USERUID}" || true)"
	if [[ -n "${EXISTING_USER}" ]]; then
		EXISTING_USERNAME="$(cut -d: -f1 <<<"${EXISTING_USER}")"
		echo "[WARN] User ${USERUID} already exists. Renaming to '${USERNAME}'."
		usermod \
			--login "${USERNAME}" \
			--home "/home/${USERNAME}" \
			--move-home \
			--shell "${DEFAULT_SHELL}" \
			"${EXISTING_USERNAME}"
		USER_EXISTS=true
	else
		USER_EXISTS=false
	fi
fi

EXISTING_GROUP="$(getent group "${USERGID}" | cut -d: -f1 || true)"
if [[ -z "${EXISTING_GROUP}" ]]; then
	if getent group "${USERNAME}" >/dev/null 2>&1; then
		echo "[FAIL] Group '${USERNAME}' already exists with a different GID." >&2
		exit 1
	fi
	groupadd --gid "${USERGID}" "${USERNAME}"
	EXISTING_GROUP="${USERNAME}"
fi

if [[ "${USER_EXISTS}" == "false" ]]; then
	useradd \
		--uid "${USERUID}" \
		--gid "${EXISTING_GROUP}" \
		--create-home \
		--home-dir "/home/${USERNAME}" \
		--shell "${DEFAULT_SHELL}" \
		"${USERNAME}"
else
	CURRENT_UID="$(id -u "${USERNAME}")"
	CURRENT_GID="$(id -g "${USERNAME}")"
	if [[ "${CURRENT_UID}" != "${USERUID}" ]]; then
		UID_OWNER="$(getent passwd "${USERUID}" | cut -d: -f1 || true)"
		if [[ -n "${UID_OWNER}" && "${UID_OWNER}" != "${USERNAME}" ]]; then
			echo "[FAIL] UID ${USERUID} is already used by '${UID_OWNER}'." >&2
			exit 1
		fi
		usermod --uid "${USERUID}" "${USERNAME}"
	fi
	if [[ "${CURRENT_GID}" != "${USERGID}" ]]; then
		usermod --gid "${EXISTING_GROUP}" "${USERNAME}"
	fi
	usermod --shell "${DEFAULT_SHELL}" "${USERNAME}"
fi

echo "${USERNAME} ALL=(root) NOPASSWD:ALL" >/etc/sudoers.d/"${USERNAME}"
chmod 0440 /etc/sudoers.d/"${USERNAME}"

INSTALL_ZSH="${INSTALLZSH:-true}"
INSTALL_OMZ="${INSTALLOMZ:-true}"
OMZ_THEME="${OMZTHEME:-agnoster}"

if [[ "${INSTALL_OMZ}" == "true" && "${INSTALL_ZSH}" != "true" ]]; then
	echo "[WARN] installOMZ requires installZsh; skipping Oh-My-Zsh installation."
	INSTALL_OMZ="false"
fi

if [[ "${INSTALL_OMZ}" == "true" ]]; then
	if [[ ! "${OMZ_THEME}" =~ ^[a-zA-Z0-9_-]+$ ]]; then
		echo "[FAIL] Invalid OMZ theme name: ${OMZ_THEME}" >&2
		exit 1
	fi

	USER_HOME="$(getent passwd "${USERNAME}" | cut -d: -f6)"
	USER_GROUP="$(id -gn "${USERNAME}")"

	su -s /bin/bash - "${USERNAME}" -c \
		'RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://install.ohmyz.sh)"'

	sed -i "s/^ZSH_THEME=.*/ZSH_THEME=\"${OMZ_THEME}\"/" "${USER_HOME}/.zshrc"
	if [[ "${OMZ_THEME}" == "agnoster" ]]; then
		cat >>"${USER_HOME}/.zshrc" <<EOF
# Customize agnoster for containers
prompt_context() {
  prompt_segment black default "%(!.%{%F{yellow}%}.)${USERNAME}"
}
EOF
	fi

	chown -R "${USERNAME}:${USER_GROUP}" "${USER_HOME}/.oh-my-zsh" "${USER_HOME}/.zshrc"
fi
