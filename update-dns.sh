# MAKE SURE NAMESPACE IS CORRECT
DOMAIN1="glitcher-gitea"
DOMAIN2="glitcher-grafana"
NAMESPACE="monitoring"
VAULT_NAME="glitcher-vault"
DYNU_TOKEN="dynu-token"
SERVICE="traefik"
MAX_TRIES=20
SLEEP_SEC=3

# Get token from Azure Key Vault
DYNUDNS_TOKEN=$(az keyvault secret show --vault-name "$VAULT_NAME" --name "$DYNU_TOKEN" --query "value" -o tsv)

# Get IP (retry loop)
COUNT=0
while [ "$COUNT" -lt "$MAX_TRIES" ]; do
  IP=$(kubectl get svc "$SERVICE" -n "$NAMESPACE" -o jsonpath="{.status.loadBalancer.ingress[0].ip}" 2>/dev/null || true)
  echo "Attempt $COUNT: IP = $IP"
  test -n "$IP" && break
  sleep "$SLEEP_SEC"
  COUNT=$((COUNT + 1))
done

# update root domain (glitcher.ddnsfree.com)
curl -X POST "https://api.dynu.com/v2/dns/12259938" -H "accept: application/json" -H "API-Key: $DYNUDNS_TOKEN" -H "Content-Type: application/json" -d "{\"name\":\"somedomain.com\",\"group\":\"\",\"ipv4Address\":\"$IP\",\"ipv6Address\":\"\",\"ttl\":90,\"ipv4\":true,\"ipv6\":true,\"ipv4WildcardAlias\":true,\"ipv6WildcardAlias\":true,\"allowZoneTransfer\":false,\"dnssec\":false}"

# update subdomain (grafana.glitcher.ddnsfree.com)
curl -X POST "https://api.dynu.com/v2/dns/12259938/record/14879311" -H "accept: application/json" -H "API-Key: $DYNUDNS_TOKEN" -H "Content-Type: application/json" -d "{\"nodeName\":\"grafana\",\"recordType\":\"A\",\"ttl\":300,\"state\":true,\"group\":\"\",\"ipv4Address\":\"${IP}\"}"

# update subdomain (boutique.glitcher.ddnsfree.com)
curl -X POST "https://api.dynu.com/v2/dns/12259938/record/14879326" -H "accept: application/json" -H "API-Key: $DYNUDNS_TOKEN" -H "Content-Type: application/json" -d "{\"nodeName\":\"boutique\",\"recordType\":\"A\",\"ttl\":300,\"state\":true,\"group\":\"\",\"ipv4Address\":\"${IP}\"}"

#Get root domain ID: curl -X GET "https://api.dynu.com/v2/dns/getroot/glitcher.ddnsfree.com" -H "accept: application/json" -H "API-Key: $API_KEY"
#Get DNS Record: curl -X GET "https://api.dynu.com/v2/dns/12259938/record" -H "accept: application/json" -H "API-Key: $API_KEY"
# domain: 12259938
# grafana: 14879311
# boutique: 14879326