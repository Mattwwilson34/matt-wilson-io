#!/bin/bash
# Sets up nginx configuration for the domain

set -e  # Exit on any error

DOMAIN_NAME=$1
if [ -z "$DOMAIN_NAME" ]; then
    echo "❌ Usage: $0 <domain_name>"
    exit 1
fi

echo "🌐 Setting up nginx for $DOMAIN_NAME..."

# Create nginx site configuration
sudo tee /etc/nginx/sites-available/$DOMAIN_NAME > /dev/null <<EOF
server {
    listen 80;
    server_name $DOMAIN_NAME www.$DOMAIN_NAME;
    root /var/www/$DOMAIN_NAME;
    index index.html;
    
    location / {
        try_files \$uri \$uri/ =404;
    }
    
    # Basic security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    
    # Hide nginx version
    server_tokens off;
    
    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types text/plain text/css text/xml text/javascript application/javascript application/xml+rss application/json;
}
EOF

# Enable site (remove default first)
sudo rm -f /etc/nginx/sites-enabled/default
sudo ln -sf /etc/nginx/sites-available/$DOMAIN_NAME /etc/nginx/sites-enabled/

# Test and reload
sudo nginx -t && sudo systemctl reload nginx

echo "✅ Nginx configured for $DOMAIN_NAME"

---

#!/bin/bash
# scripts/setup-ssl.sh
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

---

#!/bin/bash
# scripts/setup-security-headers.sh
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
    add_header Content-Security-Policy-Report-Only "default-src '\''self'\''; script-src '\''none'\''; style-src '\''self'\''; img-src '\''self'\''; font-src '\''self'\''; connect-src '\''none'\''; object-src '\''none'\''; base-uri '\''self'\''; form-action '\''none'\''; frame-ancestors '\''none'\''; upgrade-insecure-requests" always;' /etc/nginx/sites-available/$DOMAIN_NAME

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
