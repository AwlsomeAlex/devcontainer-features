#!/usr/bin/env bash

source dev-container-features-test-lib

check "custom user exists" getent passwd devcontainer
check "custom user uses bash" bash -c 'test "$(getent passwd devcontainer | cut -d: -f7)" = "/bin/bash"'
check "zsh is not installed" bash -c '! command -v zsh'
check "Oh-My-Zsh is not installed" bash -c '! test -e /home/devcontainer/.oh-my-zsh'
check "custom user's sudoers file is valid" visudo -cf /etc/sudoers.d/devcontainer

reportResults
