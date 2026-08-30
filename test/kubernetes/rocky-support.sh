#!/usr/bin/env bash

source dev-container-features-test-lib

check "kubectl is installed" command -v kubectl
check "Helm is installed" command -v helm
check "k9s is installed" command -v k9s
check "kind is installed" command -v kind
check "Minikube is installed" command -v minikube

reportResults
