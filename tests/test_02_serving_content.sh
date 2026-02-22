#!/usr/bin/env bash
# Test Exercise 2 — Serving Content

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

echo ""
echo "${BOLD}Exercise 2 — Serving Content${RESET}"
echo ""

# 2.1 Document root exists
assert "Document root /var/www/html exists" ssh_vm "test -d /var/www/html"

# 2.2 Default page is served
page=$(ssh_vm "curl -s localhost")
assert_contains "Default page returns content" "$page" "<"

# 2.3 Modify page and verify
ssh_vm "echo '<h1>Apache Test</h1>' | sudo tee /var/www/html/index.html" >/dev/null
modified=$(ssh_vm "curl -s localhost")
assert_contains "Modified page is served" "$modified" "Apache Test"

# 2.4 HTTP 200 for existing page
code=$(ssh_vm "curl -s -o /dev/null -w '%{http_code}' localhost")
assert_contains "Existing page returns 200" "$code" "200"

# 2.5 HTTP 404 for missing page
code404=$(ssh_vm "curl -s -o /dev/null -w '%{http_code}' localhost/nonexistent_test_page")
assert_contains "Missing page returns 404" "$code404" "404"

# 2.6 Access log records requests
sleep 1
log=$(ssh_vm "sudo tail -5 /var/log/apache2/other_vhosts_access.log 2>/dev/null || sudo tail -5 /var/log/apache2/access.log 2>/dev/null")
assert_contains "Access log records GET requests" "$log" "GET"

report_results "Exercise 2"
