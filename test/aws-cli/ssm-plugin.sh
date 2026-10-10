#!/usr/bin/env bash

source dev-container-features-test-lib

check "Session Manager plugin is installed" command -v session-manager-plugin
check "Session Manager plugin reports its version" session-manager-plugin --version

reportResults
