#!/bin/bash
# Script to generate SSH key pair for AWS EC2 access

set -e

KEY_DIR=".ssh"
KEY_NAME="id_rsa"

echo "🔑 Generating SSH key pair for AWS EC2..."

# Create .ssh directory if it doesn't exist
mkdir -p "$KEY_DIR"

# Check if key already exists
if [ -f "$KEY_DIR/$KEY_NAME" ]; then
    echo "⚠️  SSH key already exists at $KEY_DIR/$KEY_NAME"
    read -p "Do you want to overwrite it? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Keeping existing key."
        exit 0
    fi
fi

# Generate SSH key pair
ssh-keygen -t rsa -b 4096 -f "$KEY_DIR/$KEY_NAME" -N "" -C "inventory-api-ec2-key"

echo "✅ SSH key pair generated successfully!"
echo ""
echo "📋 Next steps:"
echo "1. The public key is at: $KEY_DIR/$KEY_NAME.pub"
echo "2. Terraform will use this key to access your EC2 instance"
echo "3. Keep the private key ($KEY_DIR/$KEY_NAME) secure and never share it!"
echo ""
echo "🔒 To SSH into your EC2 instance after it's created:"
echo "   ssh -i $KEY_DIR/$KEY_NAME ec2-user@<EC2_PUBLIC_IP>"

