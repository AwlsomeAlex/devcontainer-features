# Infrastructure as Code

Installs [OpenTofu](https://opentofu.org/) and [Terragrunt](https://terragrunt.gruntwork.io/) from their official GitHub releases.

The `tofu` and `terragrunt` executables are installed into `/usr/local/bin`.

When used with VS Code, the feature also recommends the HashiCorp HCL and OpenTofu extensions.

## Options

### `opentofuVersion`

The OpenTofu version to install. The default is `latest`. Pinned versions such as `1.12.6` are supported.

### `terragruntVersion`

The Terragrunt version to install. The default is `latest`. Pinned versions such as `1.1.4` are supported.

## Example

```json
{
  "features": {
    "ghcr.io/awlsomealex/devcontainer-features/iac:0": {}
  }
}
```

To install specific versions:

```json
{
  "features": {
    "ghcr.io/awlsomealex/devcontainer-features/iac:0": {
      "opentofuVersion": "1.12.6",
      "terragruntVersion": "1.1.4"
    }
  }
}
```

The feature supports Ubuntu and RHEL-compatible distributions, including Ubuntu 26.04 and RHEL-compatible major version 10. It supports `amd64` and `arm64` hosts and verifies downloaded releases with their published SHA-256 checksums.
