#!/usr/bin/env bash

source dev-container-features-test-lib

check "vscode user exists" getent passwd vscode
check "vscode has UID 1000" bash -c 'test "$(id -u vscode)" = "1000"'
check "vscode has GID 1000" bash -c 'test "$(id -g vscode)" = "1000"'
check "vscode uses zsh" bash -c 'test "$(getent passwd vscode | cut -d: -f7)" = "/bin/zsh"'
check "Oh-My-Zsh is installed for vscode" test -d /home/vscode/.oh-my-zsh
check "vscode sudoers file is valid" visudo -cf /etc/sudoers.d/vscode
check "LANG is configured" bash -c 'su -s /bin/bash - vscode -c '"'"'test "$LANG" = "en_US.UTF-8"'"'"''
check "LC_ALL is configured" bash -c 'su -s /bin/bash - vscode -c '"'"'test "$LC_ALL" = "en_US.UTF-8"'"'"''

reportResults
