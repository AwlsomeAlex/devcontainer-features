
# Infrastructure as Code (iac)

Installs OpenTofu and Terragrunt from their official GitHub releases.

## Example Usage

```json
"features": {
    "ghcr.io/AwlsomeAlex/devcontainer-features/iac:0": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| opentofuVersion | Specify the OpenTofu version to install, or latest. | string | latest |
| terragruntVersion | Specify the Terragrunt version to install, or latest. | string | latest |

## Customizations

### VS Code Extensions

- `hashicorp.hcl`
- `opentofu.vscode-opentofu`



---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/AwlsomeAlex/devcontainer-features/blob/main/src/iac/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
