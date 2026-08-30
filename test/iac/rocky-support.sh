#!/usr/bin/env bash

source dev-container-features-test-lib

check "OpenTofu is installed" command -v tofu
check "OpenTofu reports a version" bash -c 'tofu version'
check "Terragrunt is installed" command -v terragrunt
check "Terragrunt reports a version" bash -c 'terragrunt --version'

reportResults
