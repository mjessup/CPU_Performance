#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

SCRIPT_NAME="set_cpu_performance.sh"
SCRIPT_PATH="/root/scripts/$SCRIPT_NAME"
GITHUB_RAW_URL="https://raw.githubusercontent.com/mjessup/scripts/main/$SCRIPT_NAME"

echo -e "${YELLOW}Starting setup for CPU Performance Script...${NC}"

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check if curl is installed
if ! command_exists curl; then
    echo "Error: curl is not installed. Please install curl and try again."
    exit 1
fi

# Check if the script already exists
if [ -f "$SCRIPT_PATH" ]; then
    echo "Existing script found. Checking for updates..."
    
    # Download the latest version to a temporary file
    TMP_SCRIPT=$(mktemp)
    if curl -s "$GITHUB_RAW_URL" -o "$TMP_SCRIPT"; then
        if cmp -s "$SCRIPT_PATH" "$TMP_SCRIPT"; then
            echo -e "${GREEN}The existing script is up to date.${NC}"
            rm "$TMP_SCRIPT"
        else
            echo "Updating to the latest version..."
            mv "$TMP_SCRIPT" "$SCRIPT_PATH"
            chmod +x "$SCRIPT_PATH"
            echo -e "${GREEN}Script updated successfully.${NC}"
        fi
    else
        echo "Failed to download the latest version. Keeping the existing script."
        rm "$TMP_SCRIPT"
    fi
else
    echo "Downloading the CPU performance script..."
    if curl -s "$GITHUB_RAW_URL" -o "$SCRIPT_PATH"; then
        chmod +x "$SCRIPT_PATH"
        echo -e "${GREEN}Script downloaded and installed successfully.${NC}"
    else
        echo "Failed to download the script. Please check your internet connection and try again."
        exit 1
    fi
fi

# Check if cron jobs already exist
CRON_REBOOT=$(crontab -l 2>/dev/null | grep "@reboot $SCRIPT_PATH")
CRON_PERIODIC=$(crontab -l 2>/dev/null | grep "0 */6 \* \* \* $SCRIPT_PATH")

if [ -z "$CRON_REBOOT" ]; then
    echo "Adding cron job to run at reboot..."
    (crontab -l 2>/dev/null; echo "@reboot $SCRIPT_PATH") | crontab -
else
    echo -e "${GREEN}Cron job for reboot already exists.${NC}"
fi

if [ -z "$CRON_PERIODIC" ]; then
    echo "Adding cron job to run every 6 hours..."
    (crontab -l 2>/dev/null; echo "0 */6 * * * $SCRIPT_PATH") | crontab -
else
    echo -e "${GREEN}Cron job for periodic execution already exists.${NC}"
fi

echo -e "${GREEN}Setup complete!${NC}"
echo "The CPU performance script is located at: $SCRIPT_PATH"
echo "It will run at system reboot and every 6 hours."
echo "Logs will be stored in: /root/scripts/logs/"
echo -e "${YELLOW}You can manually run the script at any time with: $SCRIPT_PATH${NC}"
