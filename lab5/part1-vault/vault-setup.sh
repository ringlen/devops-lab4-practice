#!/bin/sh

vault secrets enable -path=secret kv-v2

# Запис і читання секрету
vault kv put secret/myapp/config username="admin" password="supersecret123"
vault kv get secret/myapp/config

# Автентифікація Kubernetes
vault auth enable kubernetes
vault write auth/kubernetes/config \
  kubernetes_host="https://$KUBERNETES_PORT_443_TCP_ADDR:443"

# Політика лише на читання
vault policy write vault-demo-policy - <<EOF
path "secret/data/myapp/*" {
  capabilities = ["read"]
}
EOF

# Роль, що пов'язує ServiceAccount, namespace і політику
vault write auth/kubernetes/role/vault-demo \
  bound_service_account_names=vault-demo-sa \
  bound_service_account_namespaces=default \
  policies=vault-demo-policy \
  ttl=1h