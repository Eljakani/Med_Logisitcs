#!/bin/bash

# Script to install Apache, configure it, and serve a website from the 'website' folder

set -e  # Exit on error

echo "=== Apache Installation and Setup Script ==="
echo ""

# Update system packages
echo "[1/5] Updating system packages..."
sudo apt-get update -y
sudo apt-get upgrade -y

# Install Apache
echo "[2/5] Installing Apache web server..."
sudo apt-get install -y apache2

# Enable Apache to start on boot
echo "[3/5] Enabling Apache to start on boot..."
sudo systemctl enable apache2

# Create website directory if it doesn't exist
echo "[4/5] Setting up website directory..."
WEBSITE_DIR="/var/www/website"
if [ ! -d "$WEBSITE_DIR" ]; then
    sudo mkdir -p "$WEBSITE_DIR"
    echo "Created $WEBSITE_DIR"
fi

# Set proper permissions
sudo chown -R www-data:www-data "$WEBSITE_DIR"
sudo chmod -R 755 "$WEBSITE_DIR"

# copy a sample index.html to the website directory
sudo cp ./website/index.html "$WEBSITE_DIR/"

# Create a default index.html if one doesn't exist
if [ ! -f "$WEBSITE_DIR/index.html" ]; then
    sudo tee "$WEBSITE_DIR/index.html" > /dev/null <<'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Welcome to My Website</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            margin: 0;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        }
        .container {
            text-align: center;
            background: white;
            padding: 40px;
            border-radius: 10px;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
        }
        h1 {
            color: #333;
            margin: 0;
        }
        p {
            color: #666;
            margin-top: 10px;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🚀 Apache is Running!</h1>
        <p>Your website is now being served by Apache.</p>
    </div>
</body>
</html>
EOF
    echo "Created default index.html"
fi

# Configure Apache virtual host
echo "[5/5] Configuring Apache virtual host..."
VHOST_FILE="/etc/apache2/sites-available/website.conf"

sudo tee "$VHOST_FILE" > /dev/null <<EOF
<VirtualHost *:80>
    ServerName localhost
    ServerAlias *
    DocumentRoot $WEBSITE_DIR
    
    <Directory $WEBSITE_DIR>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
    
    ErrorLog \${APACHE_LOG_DIR}/website_error.log
    CustomLog \${APACHE_LOG_DIR}/website_access.log combined
</VirtualHost>
EOF

# Disable default site and enable new site
sudo a2dissite 000-default 2>/dev/null || true
sudo a2ensite website

# Test Apache configuration
echo "Testing Apache configuration..."
sudo apache2ctl configtest

# Restart Apache
echo "Restarting Apache..."
sudo systemctl restart apache2

echo ""
echo "=== Setup Complete ==="
echo "✓ Apache installed and running"
echo "✓ Website directory: $WEBSITE_DIR"
echo "✓ Access your site at: http://localhost or http://<your-server-ip>"
echo ""
echo "To add your own content:"
echo "  sudo nano $WEBSITE_DIR/index.html"
echo ""
echo "To check Apache status:"
echo "  sudo systemctl status apache2"