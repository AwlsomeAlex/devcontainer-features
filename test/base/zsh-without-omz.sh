#!/usr/bin/env bash

source dev-container-features-test-lib

check "custom user exists" getent passwd devcontainer
check "zsh is installed" command -v zsh
check "custom user uses zsh" bash -c 'test "$(getent passwd devcontainer | cut -d: -f7)" = "/bin/zsh"'
check "Oh-My-Zsh is not installed" bash -c '! test -e /home/devcontainer/.oh-my-zsh'
check "custom user's sudoers file is valid" visudo -cf /etc/sudoers.d/devcontainer

reportResults
