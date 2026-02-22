#!/usr/bin/env bash
# Test Exercise 3 — SSL/TLS

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

echo ""
echo "${BOLD}Exercise 3 — SSL/TLS${RESET}"
echo ""

# 3.1 HTTPS serves content
https_page=$(ssh_vm "curl -sk https://localhost")
assert_contains "HTTPS serves content" "$https_page" "<"

# 3.2 Certificate exists
assert "SSL certificate file exists" ssh_vm "test -f /etc/ssl/certs/apache-selfsigned.crt"
assert "SSL key file exists" ssh_vm "sudo test -f /etc/ssl/private/apache-selfsigned.key"

# 3.3 Certificate has correct subject
cert_info=$(ssh_vm "echo | openssl s_client -connect localhost:443 2>/dev/null | openssl x509 -noout -subject 2>/dev/null") || true
assert_contains "Certificate has apache-lab organization" "$cert_info" "apache-lab"

# 3.4 SSL virtual host config exists
assert "SSL site config exists" ssh_vm "test -f /etc/apache2/sites-enabled/default-ssl.conf"

# 3.5 SSL config has correct directives
ssl_conf=$(ssh_vm "cat /etc/apache2/sites-enabled/default-ssl.conf")
assert_contains "SSL config has SSLEngine on" "$ssl_conf" "SSLEngine on"
assert_contains "SSL config has SSLCertificateFile" "$ssl_conf" "SSLCertificateFile"

# 3.6 Port 443 is listening
ports=$(ssh_vm "sudo ss -tlnp | grep ':443'")
assert_contains "Port 443 is listening" "$ports" ":443"

report_results "Exercise 3"
