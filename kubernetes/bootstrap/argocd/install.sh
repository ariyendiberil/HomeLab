#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
NAMESPACE="argocd"
CHART="argo/argo-cd"
RELEASE="argocd"

echo "==> Applying namespace"
kubectl apply -f "${ROOT}/kubernetes/bootstrap/argocd/namespace.yaml"

echo "==> Adding Helm repo"
helm repo add argo https://argoproj.github.io/argo-helm 2>/dev/null || true
helm repo update argo

echo "==> Installing ArgoCD"
helm upgrade --install "${RELEASE}" "${CHART}" \
  --namespace "${NAMESPACE}" \
  --create-namespace \
  -f "${ROOT}/kubernetes/bootstrap/argocd/values.yaml" \
  --wait \
  --timeout 10m

echo "==> Waiting for ArgoCD pods"
kubectl wait --for=condition=Available deployment -l app.kubernetes.io/part-of=argocd \
  -n "${NAMESPACE}" --timeout=600s 2>/dev/null || \
kubectl wait --for=condition=Ready pod -l app.kubernetes.io/name=argocd-server \
  -n "${NAMESPACE}" --timeout=600s

echo
echo "ArgoCD installed."
echo "  kubectl port-forward svc/argocd-server -n ${NAMESPACE} 8080:443"
echo "  open https://localhost:8080"
echo
echo "Initial admin password:"
kubectl -n "${NAMESPACE}" get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d
echo
