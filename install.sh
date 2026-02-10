#!/usr/bin/env bash
# apache-lab install script

set -euo pipefail

echo ""
echo "  [apache-lab] Installing..."
echo ""
echo "  This plugin demonstrates how to install and configure Apache"
echo "  as a web server with SSL/TLS and virtual hosts inside a QEMU VM."
echo ""
echo "  What you will learn:"
echo "    - How to provision Apache via cloud-init"
echo "    - How to configure virtual hosts for different sites"
echo "    - How to enable SSL/TLS with self-signed certificates"
echo "    - How to use .htaccess for access control and URL rewriting"
echo "    - How to access HTTP/HTTPS services via port forwarding"
echo ""

# Create lab working directory
mkdir -p lab

# Check for required tools
echo "  Checking dependencies..."
local_ok=true
for cmd in qemu-system-x86_64 qemu-img genisoimage curl; do
    if command -v "$cmd" &>/dev/null; then
        echo "    [OK] $cmd"
    else
        echo "    [!!] $cmd — not found (install before running)"
        local_ok=false
    fi
done

if [[ "$local_ok" == true ]]; then
    echo ""
    echo "  All dependencies are available."
else
    echo ""
    echo "  Some dependencies are missing. Install them with:"
    echo "    sudo apt install qemu-kvm qemu-utils genisoimage curl"
fi

echo ""
echo "  [apache-lab] Installation complete."
echo "  Run with: qlab run apache-lab"
