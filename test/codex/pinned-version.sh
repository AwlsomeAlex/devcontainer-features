#!/usr/bin/env bash

source dev-container-features-test-lib

VERSION="0.148.0"

check "codex is on PATH" command -v codex
check "codex reports expected version" bash -c 'codex --version | grep -F "${VERSION}"'

reportResults
