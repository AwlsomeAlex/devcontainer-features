# Dev Container CLI

Installs the [Dev Container CLI](https://github.com/devcontainers/cli) using its official installer.

The CLI is installed into `/usr/local/bin` and is available as `devcontainer`.

## Options

### `version`

The Dev Container CLI version to install. The default is `latest`.

## Example

```json
{
  "features": {
    "ghcr.io/awlsomealex/devcontainer-features/devcontainer-cli:0": {}
  }
}
```

To install a specific version:

```json
{
  "features": {
    "ghcr.io/awlsomealex/devcontainer-features/devcontainer-cli:0": {
      "version": "0.88.0"
    }
  }
}
```

The feature supports Ubuntu/Debian-compatible images and RHEL-compatible images, including Rocky Linux. It installs `curl` and `ca-certificates` as prerequisites when needed.
