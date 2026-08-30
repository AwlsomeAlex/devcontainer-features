
# Base (base)

Creates the vscode user, installs common dependencies, configures Oh-My-Zsh

## Example Usage

```json
"features": {
    "ghcr.io/AwlsomeAlex/devcontainer-features/base:0": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| username | Specify container username, if not vscode. | string | vscode |
| userUid | Specify container user's UID, if not 1000 | string | 1000 |
| userGid | Specify container user's GID, if not 1000 | string | 1000 |
| installZsh | Whether to install the ZSH shell and set it as default shell. | boolean | true |
| installOMZ | Whether to install Oh-My-Zsh and configure the user's .zshrc. Requires installZsh. | boolean | true |
| omzTheme | Specify the Oh-My-Zsh theme name to use, if not agnoster. | string | agnoster |



---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/AwlsomeAlex/devcontainer-features/blob/main/src/base/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
