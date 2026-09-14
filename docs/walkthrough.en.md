---
kicker: QLab · apache-lab
title: |
  Apache, and the
  certificate nobody trusts
subtitle: >
  Apache serving over both HTTP and HTTPS, with a certificate it signed itself.
  Every block below came out of a running lab, including the moment a client
  refuses that certificate and the reason it gives.
facts:
  - [Command, "`qlab run apache-lab`"]
  - [VM, "`apache-lab`, ports 80 and 443 forwarded to dynamic host ports"]
  - [Credentials, "`labuser` / `labpass`"]
  - [Outcome, "`qlab test apache-lab` → 6 exercises, 35 checks, all passed"]
---

## 1. What is running

{{evidence:version as=shell}}

{{evidence:processes}}

One `root` process and a set of `www-data` children. The root process exists to
bind ports 80 and 443 — below 1024, so privileged — and to re-read the
configuration; the children handle requests without privilege. Apache calls the
scheme that decides how those children are arranged an **MPM**:

{{evidence:mpm-and-modules}}

`mpm_event` is the modern default: a small number of processes, each with many
threads, and connections that are merely waiting are handed back to a listener
instead of pinning a worker. The old `mpm_prefork` — one process per connection
— is still what you get when a module is not thread-safe, which in practice
means classic `mod_php`.

The rest of that list is Apache's other defining trait: almost everything is a
module you switch on. `ssl_module` is why 443 answers at all, and
`a2enmod`/`a2dismod` are how the switch is thrown.

{{evidence:listening}}

## 2. The sites

{{evidence:sites}}

Apache separates *available* from *enabled* the same way nginx does, with
`a2ensite` and `a2dissite` managing the symlinks. Here both the plain and the
TLS site are on.

{{evidence:vhost-ssl}}

## 3. The certificate, and why a client rejects it

{{evidence:certificate as=shell}}

Read the two lines together: **subject and issuer are the same**. That is the
definition of a self-signed certificate — it vouches for itself, and there is no
authority above it that a client already trusts.

The consequence is not subtle:

{{evidence:request as=shell}}

The same page over HTTP, over HTTPS with `-k`, and over HTTPS without it. `-k`
means "do not verify"; without it the client checks the chain, finds it ends at
a certificate nobody vouched for, and refuses before sending the request.

:::note This is not a broken certificate
The encryption is exactly as strong either way. What is missing is *identity* —
a third party asserting that this server is who it claims to be. A self-signed
certificate is entirely appropriate inside a lab; on the public internet it is
what an interception attack looks like, which is why clients refuse it loudly.
:::

## 4. Apache checks its own configuration

{{evidence:configtest as=shell}}

`Syntax OK` is the answer you want before a reload. The warning above it is
worth reading rather than ignoring: with no global `ServerName`, Apache guesses
a name for itself from the host's addresses. It still works, but any behaviour
that depends on the server's own name — redirects it generates, virtual host
matching — is then resting on a guess.

{{evidence:logs}}

Two logs, and the split matters: `access.log` is one line per request,
`error.log` is where Apache explains itself. When a site returns 500 the useful
line is almost never in the first file.

## 5. Verification

{{evidence:qlab-test grep="Exercise [0-9]+:|Exercises |All exercises" as=shell}}

## 6. What to take away

- The MPM decides the concurrency model. `event` by default; `prefork` when a
  module is not thread-safe.
- Apache is modules: if a feature is missing, the module is probably just not
  enabled. `a2enmod`, then reload.
- Self-signed means subject equals issuer. The traffic is still encrypted; what
  is absent is a third party vouching for the identity.
- `-k` in curl, and "proceed anyway" in a browser, are the same decision: skip
  verification. Know when you are making it.
- Set `ServerName` globally, or Apache will guess one.
- `access.log` for what was asked, `error.log` for why it went wrong.

`guide.md` in the plugin carries the exercises: issuing the certificate, virtual
hosts, `.htaccess` and access control, and reading the logs.
