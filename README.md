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
| SSH     | 2230      | 22      |
| HTTP    | 8081      | 80      |
| HTTPS   | 8443      | 443     |

## Usage

```bash
# Install the plugin
qlab install apache-lab

# Run the lab
qlab run apache-lab

# Wait ~60s for boot and package installation, then:

# Test the web server
curl http://localhost:8081
curl -k https://localhost:8443

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

1. **Verify Apache is running**: SSH into the VM and check `systemctl status apache2`
2. **Modify the web page**: Edit `/var/www/html/index.html` and refresh from the host with `curl http://localhost:8081`
3. **Test SSL/TLS**: Run `curl -k https://localhost:8443` from the host to verify HTTPS works
4. **Create a virtual host**: Add a new site config in `/etc/apache2/sites-available/` and enable it with `a2ensite`
5. **Test .htaccess**: Create a `.htaccess` file in `/var/www/html/` with access rules (e.g., deny all, password protect)

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
