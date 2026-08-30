#!/usr/bin/env bash

source dev-container-features-test-lib

check "kubectl is version 1.35.1" bash -c 'kubectl version --client 2>/dev/null | grep -q "v1.35.1"'
check "Helm is version 4.2.4" bash -c 'helm version --short | grep -q "v4.2.4"'
check "k9s is version 0.50.18" bash -c 'k9s version --short | grep -q "v0.50.18"'
check "kind is version 0.31.0" bash -c 'kind version | grep -q "v0.31.0"'
check "Minikube is version 1.38.1" bash -c 'minikube version --short | grep -q "v1.38.1"'

reportResults
