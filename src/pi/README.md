# Pi

Installs the Pi coding agent using the official Pi installer.

## Example Usage

```json
{
    "image": "ubuntu:26.04",
    "features": {
        "ghcr.io/awlsomealex/devcontainer-features/pi:0": {}
    }
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| nodejsVersion | Node.js version to install. `latest` selects the latest Node.js 26 release. Pin a stable semver of 22.19.0 or newer, with or without a leading `v`. | string | latest |

## Requirements and supported platforms

Supports Ubuntu 26.04 and Rocky Linux 10 on `amd64` and `arm64`. The feature downloads the selected Node.js archive, which includes npm, from nodejs.org and verifies its SHA-256 checksum. It then runs Pi's official installer with `curl` to install the latest Pi release.

Pi is installed in `/usr/local/share/pi` and exposed as `/usr/local/bin/pi`. Run `pi` to start; connect a model provider in Pi before sending it tasks.
