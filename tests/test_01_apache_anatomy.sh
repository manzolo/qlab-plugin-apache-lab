#!/usr/bin/env bash
# Test Exercise 1 — Apache Anatomy

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

echo ""
echo "${BOLD}Exercise 1 — Apache Anatomy${RESET}"
echo ""

# 1.1 Apache service is running
status=$(ssh_vm "systemctl is-active apache2")
assert_contains "Apache service is active" "$status" "^active$"

# 1.2 Configuration directory structure
config_ls=$(ssh_vm "ls /etc/apache2/")
assert_contains "apache2.conf exists" "$config_ls" "apache2.conf"
assert_contains "sites-available exists" "$config_ls" "sites-available"
assert_contains "sites-enabled exists" "$config_ls" "sites-enabled"
assert_contains "mods-enabled exists" "$config_ls" "mods-enabled"

# 1.3 Ports configuration exists
ports=$(ssh_vm "cat /etc/apache2/ports.conf")
assert_contains "Listens on port 80" "$ports" "Listen 80"

# 1.4 Default site is enabled
default_sites=$(ssh_vm "ls /etc/apache2/sites-enabled/")
assert_contains "Default site config exists" "$default_sites" "default"

# 1.5 HTTP serves content
page=$(ssh_vm "curl -s localhost")
assert_contains "HTTP serves content" "$page" "<"

report_results "Exercise 1"
