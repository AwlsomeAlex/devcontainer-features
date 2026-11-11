#!/usr/bin/env bash
set -euo pipefail

command -v pi
pi --version
node --version
npm --version
node -e 'const [major] = process.versions.node.split(".").map(Number); process.exit(major === 26 ? 0 : 1)'
