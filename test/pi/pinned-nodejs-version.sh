#!/usr/bin/env bash

source dev-container-features-test-lib

check "Pi is installed" command -v pi
check "Pi reports its version" pi --version
check "Node.js 26.13.0 is installed" bash -c 'test "$(node --version)" = "v26.13.0"'

reportResults
