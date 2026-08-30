#!/usr/bin/env bash

source dev-container-features-test-lib

check "OpenTofu is version 1.12.6" bash -c 'tofu version | grep -q "OpenTofu v1.12.6"'
check "Terragrunt is version 1.1.4" bash -c 'terragrunt --version | grep -q "1.1.4"'

reportResults
