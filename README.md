# apache-lab — Apache Web Server Lab

[![QLab Plugin](https://img.shields.io/badge/QLab-Plugin-blue)](https://github.com/manzolo/qlab)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Linux-lightgrey)](https://github.com/manzolo/qlab)

A [QLab](https://github.com/manzolo/qlab) plugin that boots a virtual machine with Apache installed and configured as a web server with SSL/TLS and virtual hosts.

## Objectives

- Learn how to provision Apache via cloud-init
- Understand how Apache serves web content with virtual hosts
- Configure SSL/TLS using self-signed certificates
- Practice .htaccess rules for access control and URL rewriting
- Test HTTP/HTTPS responses from the host via port forwarding

## How It Works

1. **Cloud image**: Downloads a minimal Ubuntu 22.04 cloud image (~250MB)
2. **Cloud-init**: Creates `user-data` with Apache package installation, SSL setup, and virtual host config
3. **ISO generation**: Packs cloud-init files into a small ISO (cidata)
4. **Overlay disk**: Creates a COW disk on top of the base image (original stays untouched)
5. **QEMU boot**: Starts the VM in background with SSH, HTTP, and HTTPS port forwarding

## Credentials

- **Username:** `labuser`
- **Password:** `labpass`

## Ports

| Service | Host Port | VM Port |
|---------|-----------|---------|
| SSH     | dynamic   | 22      |
| HTTP    | dynamic   | 80      |
| HTTPS   | dynamic   | 443     |

> All host ports are dynamically allocated. Use `qlab ports` to see the actual mappings.

## Usage

```bash
# Install the plugin
qlab install apache-lab

# Run the lab
qlab run apache-lab

# Wait ~60s for boot and package installation, then:

# Test the web server (check the HTTP/HTTPS ports with 'qlab ports')
curl http://localhost:<http_port>
curl -k https://localhost:<https_port>

# Connect via SSH
qlab shell apache-lab

# Inside the VM, you can:
#   - Edit /var/www/html/index.html
#   - Check Apache status: systemctl status apache2
#   - View access logs: tail -f /var/log/apache2/access.log

# Stop the VM
qlab stop apache-lab
```

## Exercises

> **New to Apache?** See the [Step-by-Step Guide](guide.md) for complete walkthroughs with full config examples.

| # | Exercise | What you'll do |
|---|----------|----------------|
| 1 | **Apache Anatomy** | Explore Apache installation, config structure, and modules |
| 2 | **Serving Content** | Modify the default page and serve custom HTML |
| 3 | **SSL/TLS** | Configure HTTPS with self-signed certificates |
| 4 | **Virtual Hosts** | Set up multiple sites with name-based virtual hosts |
| 5 | **.htaccess and Access Control** | Configure access rules and URL rewriting |
| 6 | **Logs and Diagnostics** | Analyze access/error logs and troubleshoot issues |

## Automated Tests

An automated test suite validates the exercises against a running VM:

```bash
# Start the lab first
qlab run apache-lab
# Wait ~60s for cloud-init, then run all tests
qlab test apache-lab
```

## Resetting

To start fresh, stop and re-run:

```bash
qlab stop apache-lab
qlab run apache-lab
```

Or reset the entire workspace:

```bash
qlab reset
```
