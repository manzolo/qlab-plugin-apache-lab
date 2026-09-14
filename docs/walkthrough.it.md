---
kicker: QLab · apache-lab
title: |
  Apache, e il certificato
  di cui nessuno si fida
subtitle: >
  Apache che serve in HTTP e in HTTPS, con un certificato che si è firmato da
  solo. Ogni blocco qui sotto viene da un lab acceso, compreso il momento in cui
  un client rifiuta quel certificato e la ragione che ne dà.
facts:
  - [Comando, "`qlab run apache-lab`"]
  - [VM, "`apache-lab`, porte 80 e 443 inoltrate su porte host dinamiche"]
  - [Credenziali, "`labuser` / `labpass`"]
  - [Esito, "`qlab test apache-lab` → 6 esercizi, 35 controlli, tutti superati"]
---

## 1. Cosa sta girando

{{evidence:version as=shell}}

{{evidence:processes}}

Un processo `root` e una schiera di figli `www-data`. Il processo root esiste per
legarsi alle porte 80 e 443 — sotto la 1024, quindi privilegiate — e per
rileggere la configurazione; i figli servono le richieste senza privilegi. Lo
schema che decide come quei figli sono organizzati Apache lo chiama **MPM**:

{{evidence:mpm-and-modules}}

`mpm_event` è il default moderno: pochi processi, ciascuno con molti thread, e
le connessioni in semplice attesa vengono restituite a un listener invece di
tenere occupato un worker. Il vecchio `mpm_prefork` — un processo per
connessione — è ancora quello che si ottiene quando un modulo non è thread-safe,
che in pratica significa il classico `mod_php`.

Il resto di quell'elenco è l'altro tratto distintivo di Apache: quasi tutto è un
modulo da accendere. `ssl_module` è il motivo per cui la 443 risponde, e
`a2enmod`/`a2dismod` sono l'interruttore.

{{evidence:listening}}

## 2. I siti

{{evidence:sites}}

Apache separa *disponibile* da *attivo* come fa nginx, con `a2ensite` e
`a2dissite` a gestire i collegamenti. Qui sono accesi sia il sito in chiaro sia
quello TLS.

{{evidence:vhost-ssl}}

## 3. Il certificato, e perché un client lo rifiuta

{{evidence:certificate as=shell}}

Le due righe vanno lette insieme: **subject e issuer coincidono**. È la
definizione di certificato autofirmato — garantisce per sé stesso, e non c'è
sopra di lui nessuna autorità di cui il client già si fidi.

La conseguenza non è sottile:

{{evidence:request as=shell}}

La stessa pagina in HTTP, in HTTPS con `-k`, e in HTTPS senza. `-k` significa
«non verificare»; senza, il client controlla la catena, la trova terminata in un
certificato per cui nessuno ha garantito, e rifiuta prima ancora di mandare la
richiesta.

:::note Non è un certificato rotto
La cifratura è esattamente altrettanto robusta nei due casi. Quello che manca è
l'**identità**: un terzo che afferma che questo server è chi dice di essere. Un
certificato autofirmato è del tutto appropriato dentro un laboratorio; su
internet è l'aspetto che ha un attacco di intercettazione, ed è per questo che i
client lo rifiutano in modo rumoroso.
:::

## 4. Apache controlla la propria configurazione

{{evidence:configtest as=shell}}

`Syntax OK` è la risposta che si vuole prima di un reload. L'avviso sopra merita
di essere letto invece che ignorato: senza un `ServerName` globale, Apache si
indovina un nome a partire dagli indirizzi della macchina. Funziona lo stesso,
ma qualunque comportamento che dipenda dal nome del server — i redirect che
genera, la scelta del virtual host — poggia allora su un'ipotesi.

{{evidence:logs}}

Due log, e la divisione conta: `access.log` è una riga per richiesta,
`error.log` è dove Apache si spiega. Quando un sito restituisce 500, la riga
utile non è quasi mai nel primo file.

## 5. Verifica

{{evidence:qlab-test grep="Exercise [0-9]+:|Exercises |All exercises" as=shell}}

## 6. Cosa portarsi via

- L'MPM decide il modello di concorrenza. `event` di default; `prefork` quando
  un modulo non è thread-safe.
- Apache è fatto di moduli: se manca una funzione, probabilmente il modulo è
  solo spento. `a2enmod`, poi reload.
- Autofirmato significa subject uguale a issuer. Il traffico resta cifrato;
  quello che manca è un terzo che garantisca l'identità.
- `-k` in curl e «procedi comunque» in un browser sono la stessa decisione:
  saltare la verifica. Conviene sapere quando la si sta prendendo.
- Impostate `ServerName` globalmente, o Apache se ne indovinerà uno.
- `access.log` per cosa è stato chiesto, `error.log` per perché è andata male.

`guide.md` del plugin porta gli esercizi: emettere il certificato, i virtual
host, `.htaccess` e il controllo d'accesso, e la lettura dei log.
