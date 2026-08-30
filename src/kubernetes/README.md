# Kubernetes Tools

Installs `kubectl`, Helm, k9s, kind, and Minikube from their official release sources.

All tools are installed into `/usr/local/bin`.

## Options

The feature exposes an independent version option for each tool. Every option defaults to `latest` and accepts a pinned semantic version:

- `kubectlVersion`
- `helmVersion`
- `k9sVersion`
- `kindVersion`
- `minikubeVersion`

## Example

```json
{
  "features": {
    "ghcr.io/awlsomealex/devcontainer-features/kubernetes:0": {}
  }
}
```

To pin versions:

```json
{
  "features": {
    "ghcr.io/awlsomealex/devcontainer-features/kubernetes:0": {
      "kubectlVersion": "1.35.1",
      "helmVersion": "4.2.4",
      "k9sVersion": "0.50.18",
      "kindVersion": "0.31.0",
      "minikubeVersion": "1.38.1"
    }
  }
}
```

The feature supports Ubuntu and RHEL-compatible distributions, including Ubuntu 26.04 and RHEL-compatible major version 10. It supports `amd64` and `arm64` hosts. Helm and k9s downloads are checksum-verified; kubectl, kind, and Minikube are downloaded from their official release endpoints.
