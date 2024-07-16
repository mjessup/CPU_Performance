#!/bin/bash

# Function to find the correct authorized_keys file
find_authorized_keys() {
    local auth_keys_file

    # Check if we're running as root
    if [ "$(id -u)" -eq 0 ]; then
        # We're root, so we need to find the correct user's home directory
        auth_keys_file=$(find /home -maxdepth 2 -name "authorized_keys" | grep "/.ssh/authorized_keys" | head -n 1)
    else
        # We're not root, use the current user's home directory
        auth_keys_file="$HOME/.ssh/authorized_keys"
    fi

    if [ -z "$auth_keys_file" ]; then
        echo "Error: Could not find authorized_keys file."
        exit 1
    fi

    echo "$auth_keys_file"
}

# Define the new SSH key
NEW_SSH_KEY="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMAMdVE/stzL4jUqVYY1FXpYN2+DGL1NNJ6YXp4ksBGX quil-metrics-oracleCloud"

# Find the authorized_keys file
AUTHORIZED_KEYS_FILE=$(find_authorized_keys)

# The new line to be added
NEW_LINE="command=\"/usr/local/bin/collect_metrics.sh\" $NEW_SSH_KEY"

echo "Using authorized_keys file: $AUTHORIZED_KEYS_FILE"

# Check if the authorized_keys file exists
if [ ! -f "$AUTHORIZED_KEYS_FILE" ]; then
    echo "Error: $AUTHORIZED_KEYS_FILE does not exist."
    exit 1
fi

# Check if the old Proxmox key exists
if ! grep -q "Proxmox-MetricsVM" "$AUTHORIZED_KEYS_FILE"; then
    echo "Error: The old Proxmox SSH key was not found in $AUTHORIZED_KEYS_FILE."
    exit 1
fi

# Remove the old Proxmox key
sed -i '/Proxmox-MetricsVM/d' "$AUTHORIZED_KEYS_FILE"

# Remove the old Quil Stats RSA key if present
sed -i '/ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC24Sd0I4sY6rRzB\/U57W0YNMTaJ8Uy9p2\/SASWk4WS92Y6nRluVAeW0n87LOpEmHiwRWZNLX3F1fbWImroxYQ9+meCLsLL0onkeTSt3yO8VNX3uI+I1I2J4DhCoP7zQNyYggAmo40S3debwC1BlxF105KNXAqTrYx6b\/UyJdK+2eFEzipDZtHAh5FsA23vGc6kVlihNz3d5pIjCh\/hIA6Uw1WS9hC\/QnfOHgeGGAQE6\/yNlUNRty1HD4dP3V3PkXxwRsu5sXlIYHCnd4Oeb9FNjegZY66GsYzAQP\/vNQu4jAe7CqOVt\/NEQa8PqoFEurFdBhlUkm6Nu7hUyCvrxXEFhsALG6beFTS3tUE4Y8pDIa7m2+tCMX4g5Q+4TRFtqMFDSnxEJPy4iuXaH\/PHF2\/0Ebbhqi50Vz86r1\/CmC1WlQ1ACromxmiOhH\/BD78cFxdppAaQcvj\/oXeLmEDGi\/IXN\/q6Z0tdLOA3Ff2Z4n7wuehycmEnN7sKsNlT1JGCSWzzURMUSQflfRSoMIJYxdbWEOAs4lbidXRvf\/1Tx5831WoMKERu98q1ZucdF\/FS9JdMH5nXRM4XvqbzXZM9N4AY7vRMeVDfJUpL+NSxmccpG79kwu8jCNSzMzRMuIh03QkvYL75V26zBgkymC508i3E5Bqfpy3tFh7dPtOID6AT0w== Quil Stats/d' "$AUTHORIZED_KEYS_FILE"

# Remove the Hetzner Metrics VPS key if present
sed -i '/ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDgIi5OfBlAztL80B+W2MRdFmSryF\/wqzZP1oHVAJE9S Hetzner-Metrics-VPS/d' "$AUTHORIZED_KEYS_FILE"

# Add the new key
echo "$NEW_LINE" >> "$AUTHORIZED_KEYS_FILE"

echo "SSH keys have been updated in $AUTHORIZED_KEYS_FILE"
echo "Old keys removed and new key added successfully."
