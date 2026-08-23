# Awlsome Dev Container Features

Just a few Dev Container features I'll most likely use on my journey. I make no guarentees they'll work in your environment because I certainly can't guarantee they'll work in mind out of the gate.

I plan on supporting at least Ubuntu 26.04 and Rocky Linux 10, along with amd64 and arm64 hosts. I also plan on making these features simple enough to where if additional distributions need to be supported, it shouldn't be too much of a hassle.

## Contents

### WIP -- `base`

Creates the expected `vscode` user, installs some commonly required packages like `ca-credentials`, `curl`, `zsh`, etc. and installs Oh-My-Zshrc. The username, whether OMZ, and which theme it uses is configurable. This is similar to `common-utils`. I will try my best not to make this a HARD dependency of my units to keep it supported with `common-utils`.

```jsonc
{
    "image": "ubuntu:26.04",
    "features": {
        "ghcr.io/awlsomealex/devcontainer-features/base:0.1": {
            "username": "vscode",
            "install-zsh": true,
            "install-omz": true,
            "omz-theme": "agnoster"
        }
    }
}
````

### `codex`

Installs the OpenAI Codex CLI and ChatGPT VSCode extension to your container. You can specify `version` to choses which Codex CLI to grab from the [upstream GitHub project](https://github.com/openai/codex).

```jsonc
{
    "image": "ubuntu:26.04",
    "features": {
        "ghcr.io/awlsomealex/devcontainer-features/codex:0.1": {
            "version": "latest"
        }
    }
}
```

It's also recommended that you either bind mount `.codex` to your local home or a dedicated `codex-home` volume mount (suffix with a `-${devcontainerId}` if you desire a unique `.codex` directory for your project).

```jsonc
{
    "mounts": [
        {
            "source": "codex-home",
            "target": "/home/vscode/.codex",
            "type": "volume"
        }
    ]
}
```

OR

```jsonc
{
    "mounts": [
        {
            "source": "${localEnv:HOME}/.codex",
            "target": "/home/vscode/.codex",
            "type": "bind"
        }
    ]
}
```

### LazyGit

Installs the LazyGit TUI for git (TUIs rock). There are no options other than specifying a version, otherwise it defaults to whatevers latest.

```jsonc
{
    "image": "ubuntu:26.04",
    "features": {
        "ghcr.io/awlsomealex/devcontainer-features/lazygit:0.1": {}
    }
}
````