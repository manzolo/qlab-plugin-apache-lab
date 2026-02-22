#!/usr/bin/env bash
# Test Exercise 5 — .htaccess and Access Control

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

echo ""
echo "${BOLD}Exercise 5 — .htaccess and Access Control${RESET}"
echo ""

# 5.1 Install htpasswd if needed
ssh_vm "which htpasswd || sudo apt-get install -y apache2-utils" >/dev/null 2>&1
assert "htpasswd is available" ssh_vm "which htpasswd"

# 5.2 Create password file and protected dir
ssh_vm "sudo htpasswd -cb /etc/apache2/.htpasswd admin secret123" >/dev/null 2>&1
ssh_vm "sudo mkdir -p /var/www/html/secret && echo '<h1>Secret</h1>' | sudo tee /var/www/html/secret/index.html" >/dev/null

# 5.3 Create .htaccess
ssh_vm "sudo tee /var/www/html/secret/.htaccess > /dev/null << 'EOF'
AuthType Basic
AuthName \"Restricted\"
AuthUserFile /etc/apache2/.htpasswd
Require valid-user
EOF"

# 5.4 Unauthenticated returns 401
code_noauth=$(ssh_vm "curl -s -o /dev/null -w '%{http_code}' localhost/secret/")
assert_contains "Unauthenticated request returns 401" "$code_noauth" "401"

# 5.5 Correct credentials return 200
code_auth=$(ssh_vm "curl -s -o /dev/null -w '%{http_code}' -u admin:secret123 localhost/secret/")
assert_contains "Correct credentials return 200" "$code_auth" "200"

# 5.6 Content is returned with auth
content=$(ssh_vm "curl -s -u admin:secret123 localhost/secret/")
assert_contains "Protected content is returned" "$content" "Secret"

# 5.7 Wrong credentials return 401
code_wrong=$(ssh_vm "curl -s -o /dev/null -w '%{http_code}' -u admin:wrongpass localhost/secret/")
assert_contains "Wrong credentials return 401" "$code_wrong" "401"

# Cleanup
ssh_vm "sudo rm -rf /var/www/html/secret; sudo rm -f /etc/apache2/.htpasswd /var/www/html/.htaccess" >/dev/null 2>&1

report_results "Exercise 5"
