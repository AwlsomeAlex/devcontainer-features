FROM ubuntu:26.04

ARG DEVCONTAINER_CLI_VERSION=0.88.0

# Install required packages: git + install script requirements
RUN DEBIAN_FRONTEND=noninteractive apt-get update \
    && apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    iptables \
    jq \
    openssh-client \
    ripgrep \
    shellcheck \
    shfmt \
    sudo \
    git \
    git-lfs \
    language-pack-en \
    xz-utils \
    zsh \
    && update-locale LANG=en_US.UTF-8 \
    && rm -rf /var/lib/apt/lists/*

ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

# Ubuntu 26.04 reserves 1000:1000 UID:GID for 'ubuntu'
# Rename it to keep a consistent 'vscode' user across devcontainer bases
# TODO: Better 'sudo' handling
RUN usermod \
    --login vscode \
    --home /home/vscode \
    --move-home \
    --shell /bin/zsh \
    ubuntu \
    && groupmod --new-name vscode ubuntu \
    && echo vscode ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/vscode \
    && chmod 0440 /etc/sudoers.d/vscode

# Install devcontainer-cli using install script
RUN curl -fsSL https://raw.githubusercontent.com/devcontainers/cli/main/scripts/install.sh -o /tmp/install.sh \
    && chmod +x /tmp/install.sh \
    && sh /tmp/install.sh --version "${DEVCONTAINER_CLI_VERSION}" --prefix /usr/local/devcontainers/ \
    && rm /tmp/install.sh

ENV PATH="/usr/local/devcontainers/bin:${PATH}"
ENV HOME=/home/vscode

USER vscode

# Install Oh-My-Zsh
RUN RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://install.ohmyz.sh)" \
    && sed -i 's/^ZSH_THEME=.*/ZSH_THEME="agnoster"/' "$HOME/.zshrc" \
    && cat >> "$HOME/.zshrc" <<'EOF'
# Customize agnoster for containers
prompt_context() {
  prompt_segment black default "%(!.%{%F{yellow}%}.)vscode"
}
EOF

USER root

CMD ["/bin/zsh"]