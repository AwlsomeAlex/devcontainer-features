#!/usr/bin/env bash

source dev-container-features-test-lib

check "codex is on PATH" command -v codex
check "codex is executable" bash -c 'codex --version'

reportResults
