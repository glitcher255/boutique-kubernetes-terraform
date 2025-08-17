VAULT_NAME="glitcher-vault"
GRAFANA_SECRET_NAME="grafana-admin-password"
SLACK_URI_NAME="slack-uri"
GRAFANA_PASSWORD=$(az keyvault secret show --vault-name "$VAULT_NAME" --name "$GRAFANA_SECRET_NAME" --query value -o tsv)
SLACK_URI=$(az keyvault secret show --vault-name "$VAULT_NAME" --name "$SLACK_URI_NAME" --query value -o tsv)

kubectl create namespace monitoring

helm repo add jetstack https://charts.jetstack.io
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo add traefik https://traefik.github.io/charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add open-telemetry https://open-telemetry.github.io/opentelemetry-helm-charts
helm repo update

kubectl apply -f https://raw.githubusercontent.com/traefik/traefik/v2.10/docs/content/reference/dynamic-configuration/kubernetes-crd-definition-v1.yml

helm upgrade --install traefik traefik/traefik --namespace monitoring -f helm_values/traefik/values.yaml

kubectl apply -f helm_values/traefik/middleware.yaml

helm upgrade --install monitoring prometheus-community/kube-prometheus-stack --namespace monitoring --version 75.13.0 -f helm_values/grafana/values.yaml --set grafana.adminPassword="$GRAFANA_PASSWORD" --set-string alertmanager.config.receivers[0].slack_configs[0].api_url=$SLACK_URI

helm upgrade --install alloy grafana/alloy --namespace monitoring -f helm_values/alloy/values.yaml
helm upgrade --install loki grafana/loki --namespace monitoring --version 6.32.0 -f helm_values/loki/values.yaml

helm upgrade --install tempo grafana/tempo --namespace monitoring --version 1.23.2 -f helm_values/tempo/values.yaml
helm upgrade --install otel-collector open-telemetry/opentelemetry-collector --namespace monitoring --version 0.129.0 -f helm_values/otel/values.yaml

helm upgrade --install boutique boutique --namespace monitoring # ${path.module}

echo
echo "✅ All apps deployed to namespace 'monitoring'"