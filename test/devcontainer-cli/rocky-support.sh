#!/usr/bin/env bash

source dev-container-features-test-lib

check "devcontainer command is installed" command -v devcontainer
check "devcontainer command is executable" test -x /usr/local/bin/devcontainer
check "devcontainer command reports a version" bash -c 'devcontainer --version'

reportResults
