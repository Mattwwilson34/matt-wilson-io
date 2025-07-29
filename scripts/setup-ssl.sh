#!/bin/bash
# Sets up SSL certificate with certbot

set -e

DOMAIN_NAME=$1
if [ -z "$DOMAIN_NAME" ]; then
    echo "❌ Usage: $0 <domain_name>"
    exit 1
fi

echo "🔒 Setting up SSL for $DOMAIN_NAME..."

# Give DNS time to propagate
echo "⏳ Waiting 60 seconds for DNS propagation..."
sleep 60

# Get SSL certificate
if sudo certbot --nginx --non-interactive --agree-tos --email admin@$DOMAIN_NAME \
    -d $DOMAIN_NAME -d www.$DOMAIN_NAME --redirect; then
    echo "✅ SSL certificate installed successfully"
else
    echo "❌ SSL setup failed - check DNS settings and try again"
    exit 1
fi
