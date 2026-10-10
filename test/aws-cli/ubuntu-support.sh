#!/usr/bin/env bash

source dev-container-features-test-lib

check "AWS CLI is installed" aws --version

reportResults
