# AWS CLI

Installs AWS CLI v2 into `/usr/local/bin` using AWS's official [Linux installer](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html). Pinned versions use the documented [versioned archive names](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-version.html). The optional Session Manager plugin can be enabled for `aws ssm start-session` support.

## Options

- `version` selects the AWS CLI v2 version. It defaults to `latest`; pinned versions use the `2.x.y` format.
- `installSSMPlugin` installs the latest AWS Systems Manager Session Manager plugin when set to `true`. It defaults to `false`.

AWS documents the SSM plugin's Linux installer at an architecture-specific `latest` URL for [Ubuntu/Debian](https://docs.aws.amazon.com/systems-manager/latest/userguide/install-plugin-debian-and-ubuntu.html) and [RHEL](https://docs.aws.amazon.com/systems-manager/latest/userguide/install-plugin-linux.html). This feature therefore installs the current plugin package when enabled; the plugin has no separate pinned-version option in those instructions.

## Example

```json
{
  "features": {
    "ghcr.io/awlsomealex/devcontainer-features/aws-cli:0": {
      "version": "latest",
      "installSSMPlugin": true
    }
  }
}
```

The feature targets Ubuntu 26.04 and Rocky Linux 10 on `amd64` and `arm64`. AWS's CLI documentation provides Linux x86_64 and ARM64 installer archives; its Session Manager plugin instructions provide Debian packages for Ubuntu and RPM packages for RHEL-compatible systems, with both architectures. The AWS plugin instructions explicitly list RHEL 8 and 9; Rocky Linux 10 is included here as this repository's RHEL-compatible target.
