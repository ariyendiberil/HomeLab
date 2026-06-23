#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="platform"
SECRET="cloudflare-tunnel-credentials"

if [[ "${1:-}" == "" ]]; then
  echo "Usage: $0 <CLOUDFLARE_TUNNEL_TOKEN>"
  echo ""
  echo "Create tunnel in Cloudflare Zero Trust → Networks → Tunnels."
  echo "Public hostname service URL: http://traefik.platform.svc.cluster.local:80"
  exit 1
fi

TUNNEL_TOKEN="$1"

kubectl create namespace "$NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -

if kubectl get secret "$SECRET" -n "$NAMESPACE" >/dev/null 2>&1; then
  kubectl delete secret "$SECRET" -n "$NAMESPACE"
fi

kubectl create secret generic "$SECRET" \
  --namespace "$NAMESPACE" \
  --from-literal=TUNNEL_TOKEN="$TUNNEL_TOKEN"

echo "Created $SECRET in $NAMESPACE"
echo "Configure Cloudflare public hostname → http://traefik.platform.svc.cluster.local:80"
