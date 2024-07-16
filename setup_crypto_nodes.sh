#!/bin/bash

# Create collect_metrics.sh file and save the contents
cat << 'EOF' > /usr/local/bin/collect_metrics.sh
#!/bin/bash

cd ~/ceremonyclient/node

TIME=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
NODE_INFO=$(./node-1.4.21-linux-amd64 -node-info)
QUIL_BALANCE=$(echo "$NODE_INFO" | awk -F ': ' '/Unclaimed balance/ {print $2}')
PEER_SCORE=$(echo "$NODE_INFO" | awk -F ': ' '/Peer Score/ {print $2}')
VERSION=$(echo "$NODE_INFO" | awk -F ': ' '/Version/ {print $2}')
LOG_INFO=$(sudo journalctl -u ceremonyclient.service --no-hostname -o cat | grep '"msg":"peers in store"' | tail -n 1)
INCREMENT_LOG=$(sudo journalctl -u ceremonyclient.service --no-hostname -o cat | grep '"msg":"completed duration proof"' | tail -n 1)
PEER_STORE_COUNT=$(echo "$LOG_INFO" | jq -r '.peer_store_count')
NETWORK_PEER_COUNT=$(echo "$LOG_INFO" | jq -r '.network_peer_count')
INCREMENT=$(echo "$INCREMENT_LOG" | jq -r '.increment')
TIME_TAKEN=$(echo "$INCREMENT_LOG" | jq -r '.time_taken')

echo "{ \
  \"Time\": \"$TIME\", \
  \"quil_balance\": \"$QUIL_BALANCE\", \
  \"increment\": $INCREMENT, \
  \"time_taken\": $TIME_TAKEN, \
  \"peer_store_count\": $PEER_STORE_COUNT, \
  \"network_peer_count\": $NETWORK_PEER_COUNT, \
  \"peer_score\": \"$PEER_SCORE\", \
  \"version\": \"$VERSION\" \
}"
EOF

# Make collect_metrics.sh executable
chmod +x /usr/local/bin/collect_metrics.sh

# Add alias to .bashrc if it doesn't already exist
if ! grep -Fxq 'alias metrics="/usr/local/bin/collect_metrics.sh"' ~/.bashrc; then
    echo 'alias metrics="/usr/local/bin/collect_metrics.sh"' >> ~/.bashrc
    source ~/.bashrc
fi

# Update the authorized_keys file
AUTHORIZED_KEYS_FILE=~/.ssh/authorized_keys
SEARCH_STRING="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBbQHJg0TsgnoIu3Gb0Ad6cCTiUXjjNtSMWvq6qIXSV+ Proxmox-MetricsVM"
REPLACEMENT_STRING='# restrict Proxmox to only metrics\ncommand="/usr/local/bin/collect_metrics.sh" ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBbQHJg0TsgnoIu3Gb0Ad6cCTiUXjjNtSMWvq6qIXSV+ Proxmox-MetricsVM'

if grep -Fq "$SEARCH_STRING" "$AUTHORIZED_KEYS_FILE"; then
    sed -i "/$SEARCH_STRING/c\\$REPLACEMENT_STRING" "$AUTHORIZED_KEYS_FILE"
else
    echo -e "$REPLACEMENT_STRING" >> "$AUTHORIZED_KEYS_FILE"
fi

echo "Setup complete. The collect_metrics.sh script has been created and configured."
