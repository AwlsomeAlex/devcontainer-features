#!/usr/bin/env bash

source dev-container-features-test-lib

check "bubblewrap is installed" command -v bwrap
check "iptables is installed" command -v iptables
check "ShellCheck is installed" command -v shellcheck
check "shfmt is installed" command -v shfmt

reportResults
