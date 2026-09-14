# apache-lab — Apache Web Server Lab

[![QLab Plugin](https://img.shields.io/badge/QLab-Plugin-blue)](https://github.com/manzolo/qlab)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Walkthrough](https://img.shields.io/badge/walkthrough-EN%20%26%20IT-informational)](docs/walkthrough-en.pdf)

A single-VM [QLab](https://github.com/manzolo/qlab) lab with Apache preinstalled — for
learning virtual hosts, HTTPS with self-signed certificates, `.htaccess` rules and log
analysis, with the HTTP and HTTPS ports forwarded to the host.

## Quick start

```bash
qlab install apache-lab
qlab run apache-lab       # boots 1 VM (~60s)
qlab shell apache-lab     # log in: labuser / labpass
qlab test apache-lab      # run the automated checks
qlab stop apache-lab
```

Find the forwarded ports with `qlab ports`, then `curl -k https://127.0.0.1:<port>/`.

## What's inside

| # | Exercise | What you do |
|---|----------|-------------|
| 1 | Apache anatomy | installation, config structure, modules |
| 2 | Serving content | edit the default page, serve custom HTML |
| 3 | SSL/TLS | HTTPS with self-signed certificates |
| 4 | Virtual hosts | multiple name-based sites |
| 5 | `.htaccess` & access control | access rules and URL rewriting |
| 6 | Logs & diagnostics | read access/error logs, troubleshoot |

## Access

| | |
|---|---|
| **SSH** | `labuser` / `labpass` |
| **Ports** | SSH + HTTP (80) + HTTPS (443), dynamically allocated — see `qlab ports` |

## Learn more

- 📖 **[Step-by-step guide](guide.md)** — every exercise with full config examples
- 📄 **Illustrated walkthrough** — a real run, captured live: **[English](docs/walkthrough-en.pdf)** · **[Italiano](docs/walkthrough-it.pdf)**
- 🧩 **[QLab](https://github.com/manzolo/qlab)** — the plugin runner: how install, overlays and cloud-init work
