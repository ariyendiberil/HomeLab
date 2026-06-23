#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="banking-cache"
SECRET="banking-redis-auth"

if kubectl get secret "$SECRET" -n "$NAMESPACE" >/dev/null 2>&1; then
  echo "Secret $SECRET already exists in $NAMESPACE"
  exit 0
fi

kubectl create namespace "$NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -
kubectl create secret generic "$SECRET" \
  --namespace "$NAMESPACE" \
  --from-literal=password="$(openssl rand -base64 32)"

echo "Created $SECRET in $NAMESPACE"
