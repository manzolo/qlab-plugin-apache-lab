#!/usr/bin/env bash
# Test Exercise 6 — Logs and Diagnostics

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

echo ""
echo "${BOLD}Exercise 6 — Logs and Diagnostics${RESET}"
echo ""

# 6.1 Log directory exists and contains log files
log_files=$(ssh_vm "sudo ls /var/log/apache2/")
assert_contains "Log directory has files" "$log_files" "log"

# 6.2 Error log exists
assert "Error log exists" ssh_vm "sudo test -f /var/log/apache2/error.log"

# 6.3 Config validation
config_test=$(ssh_vm "sudo apachectl configtest 2>&1")
assert_contains "Config validation passes" "$config_test" "Syntax OK"

# 6.4 Ports are listening
ports=$(ssh_vm "sudo ss -tlnp | grep apache2 || sudo ss -tlnp | grep ':80'")
assert_contains "Apache is listening on port 80" "$ports" ":80"

# 6.5 Apache version info
version=$(ssh_vm "apache2 -v 2>/dev/null || apache2ctl -v 2>/dev/null")
assert_contains "Apache version info available" "$version" "Server version"

report_results "Exercise 6"
