# Apache Lab — Step-by-Step Guide

This guide walks you through understanding and configuring **Apache HTTP Server**, the world's most widely used web server for decades. Apache powers millions of websites and provides extensive module support, flexible configuration, and robust SSL/TLS capabilities.

By the end of this lab you will understand how Apache works, how to serve content with virtual hosts, configure SSL/TLS with self-signed certificates, set up access control with `.htaccess`, and diagnose common issues.

## Prerequisites

Start the lab and wait for the VM to finish booting (~60 seconds):

```bash
qlab run apache-lab
```

Open a terminal and connect to the VM:

```bash
qlab shell apache-lab
```

Make sure cloud-init has finished:

```bash
cloud-init status --wait
```

## Credentials

- **Username:** `labuser`
- **Password:** `labpass`
- **Sudo:** passwordless

## Ports

| Service | Host Port | VM Port |
|---------|-----------|---------|
| SSH     | dynamic   | 22      |
| HTTP    | dynamic   | 80      |
| HTTPS   | dynamic   | 443     |

> Use `qlab ports` on the host to see the actual port mappings.

---

## Exercise 01 — Apache Anatomy

**VM:** apache-lab
**Goal:** Understand how Apache is structured and configured.

Apache uses a modular architecture — the core handles basic HTTP, and modules add features like SSL, URL rewriting, and authentication. This design means you can enable exactly the features you need and disable everything else, reducing attack surface and resource usage.

### 1.1 Check Apache is running

```bash
systemctl status apache2
```

**Expected output:**
```
● apache2.service - The Apache HTTP Server
     Loaded: loaded (/lib/systemd/system/apache2.service; enabled; ...)
     Active: active (running) since ...
```

### 1.2 Explore the configuration directory

```bash
ls /etc/apache2/
```

**Expected output:**
```
apache2.conf  conf-available  conf-enabled  envvars  magic
mods-available  mods-enabled  ports.conf  sites-available  sites-enabled
```

Key structure:
- `apache2.conf` — main configuration file
- `sites-available/` — virtual host configurations
- `sites-enabled/` — symlinks to active virtual hosts
- `mods-available/` — all available modules
- `mods-enabled/` — symlinks to loaded modules
- `ports.conf` — which ports Apache listens on

### 1.3 Check the main configuration

```bash
cat /etc/apache2/apache2.conf | grep -v '^#' | grep -v '^$'
```

### 1.4 Check enabled modules

```bash
apache2ctl -M 2>/dev/null | head -20
```

The SSL and rewrite modules should be loaded:

```bash
apache2ctl -M 2>/dev/null | grep -E 'ssl|rewrite'
```

**Expected output:**
```
 rewrite_module (shared)
 ssl_module (shared)
```

### 1.5 Check which ports Apache listens on

```bash
cat /etc/apache2/ports.conf
```

**Expected output:**
```
Listen 80
<IfModule ssl_module>
    Listen 443
</IfModule>
```

**Verification:** `systemctl status apache2` shows `active (running)` and `apache2ctl -M` lists loaded modules.

---

## Exercise 02 — Serving Content

**VM:** apache-lab
**Goal:** Understand how Apache serves static files.

Apache's primary job is serving files from a document root directory. When a request arrives, Apache maps the URL path to a filesystem path relative to the `DocumentRoot` and returns the file.

### 2.1 Test the default page via HTTP

```bash
curl -s localhost
```

### 2.2 Check the document root

```bash
ls -la /var/www/html/
```

### 2.3 View the active site configuration

```bash
cat /etc/apache2/sites-enabled/default.conf
```

Notice `DocumentRoot /var/www/html` — this is where Apache looks for files.

### 2.4 Modify the default page

```bash
echo '<h1>Hello from apache-lab!</h1>' | sudo tee /var/www/html/index.html
```

### 2.5 Verify the change

```bash
curl -s localhost
```

**Expected output:**
```html
<h1>Hello from apache-lab!</h1>
```

### 2.6 Check the access log

```bash
sudo tail -3 /var/log/apache2/access.log
```

**Expected output (example):**
```
127.0.0.1 - - [21/Feb/2026:10:00:00 +0000] "GET / HTTP/1.1" 200 ...
```

**Verification:** `curl localhost` returns your modified content.

---

## Exercise 03 — SSL/TLS

**VM:** apache-lab
**Goal:** Understand how HTTPS works with self-signed certificates.

SSL/TLS encrypts the connection between client and server, protecting data in transit from eavesdropping and tampering. In production you'd use certificates from a Certificate Authority (Let's Encrypt), but for learning, self-signed certificates work the same way cryptographically.

### 3.1 Test HTTPS

```bash
curl -sk https://localhost
```

The `-k` flag tells curl to accept the self-signed certificate. Without it, curl would reject the connection because the certificate isn't signed by a trusted CA.

### 3.2 Examine the certificate

```bash
echo | openssl s_client -connect localhost:443 2>/dev/null | openssl x509 -noout -subject -issuer -dates
```

**Expected output:**
```
subject=CN = localhost, O = apache-lab, C = US
issuer=CN = localhost, O = apache-lab, C = US
notBefore=...
notAfter=...
```

Notice `subject` and `issuer` are the same — this is what "self-signed" means.

### 3.3 View the SSL virtual host configuration

```bash
cat /etc/apache2/sites-enabled/default-ssl.conf
```

Key directives:
- `SSLEngine on` — enables SSL for this virtual host
- `SSLCertificateFile` — path to the certificate
- `SSLCertificateKeyFile` — path to the private key

### 3.4 Check certificate and key files

```bash
sudo ls -la /etc/ssl/certs/apache-selfsigned.crt
sudo ls -la /etc/ssl/private/apache-selfsigned.key
```

### 3.5 Generate a new self-signed certificate

```bash
sudo openssl req -x509 -nodes -days 30 -newkey rsa:2048 \
    -keyout /tmp/test.key -out /tmp/test.crt \
    -subj '/CN=test.local/O=test/C=US'
```

```bash
openssl x509 -in /tmp/test.crt -noout -subject
```

**Expected output:**
```
subject=CN = test.local, O = test, C = US
```

**Verification:** `curl -sk https://localhost` returns content, and the certificate shows `apache-lab` as the organization.

---

## Exercise 04 — Virtual Hosts

**VM:** apache-lab
**Goal:** Serve multiple websites from a single Apache instance.

Virtual hosts let one Apache server handle requests for different domain names, each with its own document root and settings. Apache inspects the `Host` header in each request to decide which virtual host should handle it.

### 4.1 Create a new site directory

```bash
sudo mkdir -p /var/www/mysite
echo '<h1>Welcome to mysite.local</h1>' | sudo tee /var/www/mysite/index.html
```

### 4.2 Create a virtual host configuration

```bash
sudo tee /etc/apache2/sites-available/mysite.conf << 'EOF'
<VirtualHost *:80>
    ServerName mysite.local
    DocumentRoot /var/www/mysite
    <Directory /var/www/mysite>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
EOF
```

### 4.3 Enable the site

```bash
sudo a2ensite mysite.conf
```

**Expected output:**
```
Enabling site mysite.
To activate the new configuration, you need to run:
  systemctl reload apache2
```

### 4.4 Validate and reload

```bash
sudo apachectl configtest
sudo systemctl reload apache2
```

### 4.5 Test the virtual host

```bash
curl -s -H "Host: mysite.local" localhost
```

**Expected output:**
```html
<h1>Welcome to mysite.local</h1>
```

### 4.6 Disable the site

```bash
sudo a2dissite mysite.conf
sudo systemctl reload apache2
```

**Verification:** Virtual host responds with the correct content when using the matching `Host` header.

---

## Exercise 05 — .htaccess and Access Control

**VM:** apache-lab
**Goal:** Control access to web content using `.htaccess` files and basic authentication.

`.htaccess` files allow per-directory configuration without editing the main server config. They're useful for shared hosting where users can't modify the main Apache configuration. The `AllowOverride All` directive in our virtual host enables `.htaccess` support.

### 5.1 Install htpasswd utility

```bash
which htpasswd || sudo apt-get install -y apache2-utils
```

### 5.2 Create a password file

```bash
sudo htpasswd -cb /etc/apache2/.htpasswd admin secret123
```

### 5.3 Create a protected directory

```bash
sudo mkdir -p /var/www/html/secret
echo '<h1>Secret Area</h1>' | sudo tee /var/www/html/secret/index.html
```

### 5.4 Create .htaccess with authentication

```bash
sudo tee /var/www/html/secret/.htaccess << 'EOF'
AuthType Basic
AuthName "Restricted Area"
AuthUserFile /etc/apache2/.htpasswd
Require valid-user
EOF
```

### 5.5 Test without credentials

```bash
curl -s -o /dev/null -w "%{http_code}" localhost/secret/
```

**Expected output:**
```
401
```

### 5.6 Test with correct credentials

```bash
curl -s -u admin:secret123 localhost/secret/
```

**Expected output:**
```html
<h1>Secret Area</h1>
```

### 5.7 Test URL rewriting

```bash
sudo tee /var/www/html/.htaccess << 'EOF'
RewriteEngine On
RewriteRule ^about$ /index.html [L]
EOF
```

```bash
curl -s -o /dev/null -w "%{http_code}" localhost/about
```

**Expected output:**
```
200
```

### 5.8 Clean up

```bash
sudo rm -f /var/www/html/.htaccess /var/www/html/secret/.htaccess
sudo rm -rf /var/www/html/secret
sudo rm -f /etc/apache2/.htpasswd
```

**Verification:** Protected directories return 401 without credentials and 200 with correct credentials.

---

## Exercise 06 — Logs and Diagnostics

**VM:** apache-lab
**Goal:** Use Apache logs and tools to diagnose problems.

Effective troubleshooting starts with logs. Apache provides detailed access and error logs, plus diagnostic tools to inspect the running configuration.

### 6.1 View access log

```bash
sudo tail -5 /var/log/apache2/access.log
```

### 6.2 View error log

```bash
sudo tail -5 /var/log/apache2/error.log
```

### 6.3 Validate configuration

```bash
sudo apachectl configtest
```

**Expected output:**
```
Syntax OK
```

### 6.4 List loaded modules

```bash
apache2ctl -M 2>/dev/null
```

### 6.5 Check listening ports

```bash
sudo ss -tlnp | grep apache2
```

**Expected output:**
```
LISTEN  0  511  *:80   *:*  users:(("apache2",...))
LISTEN  0  511  *:443  *:*  users:(("apache2",...))
```

### 6.6 Check Apache version and build info

```bash
apache2ctl -V 2>/dev/null | head -10
```

### 6.7 Check virtual host configuration

```bash
apache2ctl -S 2>/dev/null
```

This shows all virtual hosts and their port bindings — invaluable for debugging routing issues.

**Verification:** `apachectl configtest` returns "Syntax OK" and logs are accessible.

---

## Troubleshooting

### Apache won't start
```bash
sudo apachectl configtest
sudo journalctl -u apache2 --no-pager -n 20
```

### "Address already in use"
```bash
sudo ss -tlnp | grep ':80\|:443'
# Kill the conflicting process or change ports
```

### SSL errors
```bash
# Verify certificate and key match
sudo openssl x509 -noout -modulus -in /etc/ssl/certs/apache-selfsigned.crt | md5sum
sudo openssl rsa -noout -modulus -in /etc/ssl/private/apache-selfsigned.key | md5sum
# Both should produce the same hash
```

### .htaccess not working
```bash
# Check AllowOverride is set to All in the Directory block
grep -r "AllowOverride" /etc/apache2/sites-enabled/
# Must be "AllowOverride All" (not "None")

# Check mod_rewrite is enabled
apache2ctl -M 2>/dev/null | grep rewrite
```

### 403 Forbidden
```bash
# Check file permissions
ls -la /var/www/html/
# Files should be readable by www-data
sudo chown -R www-data:www-data /var/www/html/
```

### Packages not installed
```bash
cloud-init status --wait
```
