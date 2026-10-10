#!/usr/bin/env bash

source dev-container-features-test-lib

check "AWS CLI is version 2.0.30" bash -c 'aws --version 2>&1 | grep -q "^aws-cli/2.0.30 "'

reportResults
