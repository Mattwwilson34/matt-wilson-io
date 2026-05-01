#!/bin/bash
# Adds security headers to nginx HTTPS configuration

set -e

DOMAIN_NAME=$1
if [ -z "$DOMAIN_NAME" ]; then
    echo "❌ Usage: $0 <domain_name>"
    exit 1
fi

echo "🛡️ Adding security headers for $DOMAIN_NAME..."

# Add security headers after the first 'listen 443' line
sudo sed -i '/listen 443.*ssl/a\
    \
    # Security Headers\
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains; preload" always;\
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;\
    add_header Content-Security-Policy "default-src '\''self'\''; script-src '\''self'\''; style-src '\''self'\'' https://fonts.googleapis.com; img-src '\''self'\''; font-src '\''self'\'' https://fonts.gstatic.com; connect-src '\''none'\''; object-src '\''none'\''; base-uri '\''self'\''; form-action '\''none'\''; frame-ancestors '\''none'\''; upgrade-insecure-requests" always;' /etc/nginx/sites-available/$DOMAIN_NAME

# Test configuration
if sudo nginx -t; then
    sudo systemctl reload nginx
    echo "✅ Security headers added successfully"
    echo "ℹ️  Starting in report-only mode for testing"
    echo "ℹ️  Change 'Content-Security-Policy-Report-Only' to 'Content-Security-Policy' when ready"
else
    echo "❌ Nginx configuration error"
    exit 1
fi
