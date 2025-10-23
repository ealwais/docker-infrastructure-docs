#!/bin/bash
# Headless rclone Google Drive setup script

echo "=== Headless rclone Google Drive Setup ==="
echo ""
echo "This script helps set up Google Drive on a headless server."
echo ""
echo "You'll need to:"
echo "1. Run 'rclone authorize \"drive\"' on a machine with a browser"
echo "2. Copy the authorization token it gives you"
echo "3. Paste it when this script asks for it"
echo ""
read -p "Do you have the authorization token ready? (y/n): " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Please run this on a machine with a browser first:"
    echo "  rclone authorize \"drive\""
    echo ""
    echo "Then run this script again with the token."
    exit 1
fi

echo ""
echo "Please paste your authorization token (it's very long):"
read -p "Token: " TOKEN

# Create rclone config
mkdir -p ~/.config/rclone
cat > ~/.config/rclone/rclone.conf << EOF
[drive]
type = drive
scope = drive
token = $TOKEN
EOF

echo ""
echo "Testing connection..."
if rclone lsd drive: > /dev/null 2>&1; then
    echo "✓ Successfully connected to Google Drive!"
    echo ""
    echo "Listing your Google Drive folders:"
    rclone lsd drive: | head -10
    echo ""
    echo "To mount Google Drive, run:"
    echo "  mkdir -p ~/google-drive"
    echo "  rclone mount drive: ~/google-drive --daemon --vfs-cache-mode writes"
else
    echo "✗ Failed to connect. Please check your token and try again."
    exit 1
fi