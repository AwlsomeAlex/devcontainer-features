#!/usr/bin/env bash

source dev-container-features-test-lib

check "Pi is installed" command -v pi
check "Pi reports its version" pi --version
check "Node.js is available" node --version
check "npm is available" npm --version
check "Node.js 26 is installed" node -e 'const [major] = process.versions.node.split(".").map(Number); process.exit(major === 26 ? 0 : 1)'

reportResults
