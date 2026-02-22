#!/usr/bin/env bash
# Test Exercise 4 — Virtual Hosts

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

echo ""
echo "${BOLD}Exercise 4 — Virtual Hosts${RESET}"
echo ""

# 4.1 Create virtual host
ssh_vm "sudo mkdir -p /var/www/mysite && echo '<h1>mysite</h1>' | sudo tee /var/www/mysite/index.html" >/dev/null

ssh_vm "sudo tee /etc/apache2/sites-available/mysite.conf > /dev/null << 'EOF'
<VirtualHost *:80>
    ServerName mysite.local
    DocumentRoot /var/www/mysite
    <Directory /var/www/mysite>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
EOF"

# 4.2 Enable site
ssh_vm "sudo a2ensite mysite.conf" >/dev/null 2>&1

# 4.3 Config validates
config_test=$(ssh_vm "sudo apachectl configtest 2>&1")
assert_contains "Config validates" "$config_test" "Syntax OK"

# 4.4 Reload
assert "Apache reload succeeds" ssh_vm "sudo systemctl reload apache2"
sleep 1

# 4.5 Virtual host responds
vhost=$(ssh_vm "curl -s -H 'Host: mysite.local' localhost")
assert_contains "Virtual host serves correct content" "$vhost" "mysite"

# 4.6 a2dissite works
ssh_vm "sudo a2dissite mysite.conf && sudo systemctl reload apache2" >/dev/null 2>&1

# Cleanup
ssh_vm "sudo rm -f /etc/apache2/sites-available/mysite.conf; sudo rm -rf /var/www/mysite" >/dev/null 2>&1

report_results "Exercise 4"
