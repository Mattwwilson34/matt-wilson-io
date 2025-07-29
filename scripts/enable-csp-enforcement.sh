#!/bin/bash
# Converts CSP from report-only to enforcement mode

set -e

DOMAIN_NAME=$1
if [ -z "$DOMAIN_NAME" ]; then
    echo "❌ Usage: $0 <domain_name>"
    exit 1
fi

echo "🛡️ Enabling CSP enforcement for $DOMAIN_NAME..."

# Check if report-only CSP exists
if sudo grep -q "Content-Security-Policy-Report-Only" /etc/nginx/sites-available/$DOMAIN_NAME; then
    # Convert report-only to enforcement
    sudo sed -i 's/Content-Security-Policy-Report-Only/Content-Security-Policy/' /etc/nginx/sites-available/$DOMAIN_NAME
    
    # Test and reload
    if sudo nginx -t; then
        sudo systemctl reload nginx
        echo "✅ CSP enforcement enabled!"
        echo "🔍 Test your site thoroughly to ensure nothing is broken"
        echo "📊 Check browser console for any CSP violations"
    else
        echo "❌ Nginx configuration error"
        exit 1
    fi
else
    echo "⚠️ No CSP report-only header found. Run setup-security-headers.sh first."
    exit 1
fi
