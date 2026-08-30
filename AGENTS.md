# Working in this repository

This repository contains Dev Container Features intended to replace repeated setup logic in the project's development-container Dockerfile. Features should be self-contained, configurable where useful, and tested against the operating systems they claim to support.

## Supported operating systems

The primary supported images are:

- Ubuntu 26.04
- Rocky Linux 10

All features must support both `amd64` and `arm64` hosts. When downloading upstream binaries, map host architecture names explicitly and fail clearly for unsupported architectures.

Use `/etc/os-release` and account for both `ID` and `ID_LIKE` when selecting the package-manager branch. The usual pattern is:

- Ubuntu-compatible images: `apt-get update`, install with `--no-install-recommends`, then clean `/var/lib/apt/lists`.
- RHEL-compatible images: install `epel-release` and `dnf-plugins-core`, enable CRB with `crb enable`, install with `--setopt=install_weak_deps=False`, then clean `/var/cache/dnf`.

Do not assume packages available in Ubuntu are also available in Rocky/EPEL, or vice versa. When a tool is unavailable from the supported OS repositories, install it from its upstream release or another documented source.

## Feature layout

Each feature belongs under `src/<feature-name>/` and normally contains:

- `devcontainer-feature.json`
- `install.sh`
- `README.md`

Feature tests belong under `test/<feature-name>/`:

- `scenarios.json` defines the images and feature options.
- `test.sh` contains the default checks.
- Every named scenario in `scenarios.json` must have a matching `<scenario-name>.sh` test script. The Dev Container feature test runner does not automatically reuse `test.sh` for named scenarios.

Use explicit image tags in scenarios. Ubuntu support scenarios must use `ubuntu:26.04`; Rocky support scenarios use `rockylinux/rockylinux:10` to cover the supported RHEL 10 major version. Feature scenarios should cover both `amd64` and `arm64` when architecture-specific behavior is involved.

## Feature options and environment variables

Dev Container Feature option names are camelCase in `devcontainer-feature.json` and arrive in `install.sh` as uppercase environment variables. For example:

- `userUid` → `USERUID`
- `userGid` → `USERGID`
- `installZsh` → `INSTALLZSH`
- `installOMZ` → `INSTALLOMZ`
- `omzTheme` → `OMZTHEME`
- `shfmt` → `SHFMT`

Avoid generic variable collisions with sourced files. In particular, `/etc/os-release` defines `VERSION`; capture a feature option named `VERSION` into a feature-specific variable before sourcing `/etc/os-release`.

Validate user-provided values before using them in commands. Usernames should be non-root system-compatible names, numeric IDs should be numeric, and version or theme values should be constrained to the formats the installer accepts.

## Current feature responsibilities

Whenever a new feature is added, update this section in the same change with a concise `TL;DR` describing what the feature installs or configures, its supported platforms, and any important options or prerequisites. Update the TL;DR whenever the feature's responsibilities materially change.

### `base`

**TL;DR:** Provides the common user, locale, package, sudo, Zsh, and optional Oh-My-Zsh setup for Ubuntu and Rocky/RHEL containers, with configurable user identity and shell options.

Base provides common environment setup:

- Common command-line dependencies
- Ubuntu and Rocky/RHEL package installation
- `en_US.UTF-8` locale configuration
- Configurable user, UID, and GID setup
- Passwordless sudo for the configured user
- Optional Zsh installation
- Optional Oh-My-Zsh installation and theme configuration

`installOMZ` requires `installZsh`; when Zsh is disabled, OMZ should be skipped with a warning.

### `codex`

**TL;DR:** Installs the OpenAI Codex CLI using its official installer and the repository's supported OS dependency handling.

Codex installs the OpenAI Codex CLI using its official installer. Preserve its supported OS dependency handling and avoid duplicating Base responsibilities unless the feature must remain independently usable.

### `devcontainer-cli`

**TL;DR:** Installs a configurable version of the Dev Container CLI into `/usr/local/bin` using the official installer.

Dev Container CLI is installed with the official Dev Container CLI installer. Its version option must not be allowed to be overwritten by `/etc/os-release` processing. The current installation target is `/usr/local/bin`.

### `extras`

**TL;DR:** Installs bubblewrap, iptables, ShellCheck, and upstream shfmt for supported Ubuntu and Rocky/RHEL containers; shfmt supports configurable latest or pinned versions on amd64 and arm64.

Extras installs:

- `bubblewrap`
- `iptables`
- `shellcheck`
- `shfmt`

The first three use the supported OS package managers. `shfmt` is not assumed to exist in EPEL and is installed from the upstream `mvdan/sh` release. Its `shfmt` option defaults to `latest`, resolves the current GitHub release tag, and supports only `amd64` and `arm64`.

## Testing expectations

Tests should verify observable behavior rather than implementation details. For OS support, check that the expected commands are installed and usable. For configurable options, test the non-default value and verify the resulting behavior.

When a user says they will test, make the requested file changes but do not run commands or tests. Otherwise, run focused feature tests first and report the exact scenarios passed or failed.

Before handoff, when testing is authorized, validate shell syntax, scenario JSON, and whitespace in addition to the relevant feature scenarios.

## Documentation

Every feature should document:

- What it installs or configures
- Available options and defaults
- Supported operating systems and architectures
- Any upstream downloads or repository enablement
- A minimal `devcontainer.json` example

Keep documentation aligned with the implementation. Do not claim broad distribution support when the package names or repository setup only support Ubuntu 26.04 and Rocky Linux 10.

## Change discipline

Preserve unrelated user changes in the worktree. Keep feature-specific logic in the feature rather than adding shared setup back to the project Dockerfile. When adding a feature that replaces Dockerfile logic, identify the remaining Dockerfile-only responsibilities instead of duplicating the feature's setup.
