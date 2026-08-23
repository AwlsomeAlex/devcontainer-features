#!/usr/bin/env bash

source dev-container-features-test-lib

check "lazygit is on PATH" command -v lazygit
check "lazygit reports expected version" bash -c 'lazygit --version | grep -F "0.64.1"'

reportResults
