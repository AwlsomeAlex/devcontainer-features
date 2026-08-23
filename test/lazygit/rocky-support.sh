#!/usr/bin/env bash

source dev-container-features-test-lib

check "lazygit is on PATH" command -v lazygit
check "lazygit is executable" bash -c 'lazygit --version'

reportResults
