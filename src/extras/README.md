# Extras

Installs additional development tools used by the development container:

- [bubblewrap](https://github.com/containers/bubblewrap)
- `iptables`
- [ShellCheck](https://www.shellcheck.net/)
- [shfmt](https://github.com/mvdan/sh)

The `shfmt` option controls the installed shfmt version and defaults to `latest`.

## Example

```json
{
  "features": {
    "ghcr.io/awlsomealex/devcontainer-features/extras:0": {}
  }
}
```

The feature supports Ubuntu and RHEL-compatible distributions, including Ubuntu 26.04 and RHEL-compatible major version 10. On RHEL-compatible distributions, EPEL and CRB are enabled before installing the tools. `shfmt` is installed from an upstream release because it is not available in EPEL. Only `amd64` and `arm64` architectures are supported.
