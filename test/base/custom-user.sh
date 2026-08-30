#!/usr/bin/env bash

source dev-container-features-test-lib

check "custom user exists" getent passwd johnt
check "custom user has UID 1001" bash -c 'test "$(id -u johnt)" = "1001"'
check "custom user has GID 1001" bash -c 'test "$(id -g johnt)" = "1001"'
check "custom user uses zsh" bash -c 'test "$(getent passwd johnt | cut -d: -f7)" = "/bin/zsh"'
check "custom user's OMZ is installed" test -d /home/johnt/.oh-my-zsh
check "custom OMZ theme is configured" grep -q 'ZSH_THEME="robbyrussell"' /home/johnt/.zshrc
check "custom sudoers file is valid" visudo -cf /etc/sudoers.d/johnt

reportResults
