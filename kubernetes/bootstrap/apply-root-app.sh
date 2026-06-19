#!/usr/bin/env bash
# Bootstrap GitOps after ArgoCD is installed (kubernetes/bootstrap/argocd/install.sh).
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

echo "==> Applying root App-of-Apps"
kubectl apply -f "${ROOT}/kubernetes/apps/root-app.yaml"

echo
echo "Root app applied. ArgoCD will sync platform apps from Git once the repo is reachable."
echo "  kubectl get applications -n argocd"
