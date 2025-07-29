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
