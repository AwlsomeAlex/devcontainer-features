
# AWS CLI (aws-cli)

Installs AWS CLI v2 and optionally the AWS Systems Manager Session Manager plugin.

## Example Usage

```json
"features": {
    "ghcr.io/AwlsomeAlex/devcontainer-features/aws-cli:0": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| version | Specify the AWS CLI v2 version to install, or latest. | string | latest |
| installSSMPlugin | Install the latest AWS Systems Manager Session Manager plugin. | boolean | false |



---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/AwlsomeAlex/devcontainer-features/blob/main/src/aws-cli/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
