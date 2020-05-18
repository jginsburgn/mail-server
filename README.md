# SMTP/IMAP Server in a Docker Image

This image combines postfix and dovecot into a secure IMAP/SMTP server. The server is enabled with virtual users, each with its own maildir. Also, it has spamassassin to detect junk email and sieve to route such emails to their proper place (the Junk mailbox).

SASL in SMTP (outgoing email) refers to relay service authentication. In other words, it is used to authenticate to an MTA (commonly SendGrid) when a user wants to send a message to a third party.

SASL in SMTPD (incoming email) refers to SMTP client authentication. It is used when mail clients want to send email through this server.

## Postfix

Postfix is the main workhorse for receiving mail through SMTP and delivering it locally (LMTP) or remotely (SMTP).

## Dovecot

Dovecot serves postfix to:

- authenticate SMTP users via SASL
- write local delivery email to maildirs
- serve maildirs via IMAP
- with sieve, it places spam-marked in the Junk mailbox

## Spamassassin

Spamassassin works as an [`after-queue filter`](http://www.postfix.org/FILTER_README.html) for postfix.

## TLS

All exposed services in this image rely on TLS. Therefore, a certificate in PEM format and its key should be located at `etc/ssl/cert.pem` and `/etc/ssl/key.pem`, respectively.

## Relevant Configurations

After a modification to one of the files do: `service dovecot restart`, `service postfix restart` or `service spamassassin restart` as needed. Most relevant configuration files are:

### `/etc/postfix/↴`

#### [`aliases`](http://www.postfix.org/virtual.5.html)

Address rewriting for delivery. This is used in order to map a recipient to another, set a catchall address and create a mailing list.

Example:

```
# Mailing list
support@example.com adam@example.com,bob@example.com

# Domain catchall address
@example.com adam@example.com

# Alias
adam@example.com bob@example.com
```

After modyfing do:

```
cd /etc/postfix
postmap aliases
```

#### `domains`

Domains that are final destination for this SMTP server. The in the table key is the domain; note that the value in the table is not used.

Example:

```
example1.com .
example2.com .
example3.com .
```

After modyfing do:

```
cd /etc/postfix
postmap domains
```

#### `mailboxes`

Users for the corresponding domains that have mailboxes. The key in the table is the user; note that the value in the table is not used.

Example:

```
adam@example1.com adam
bob@example2.com bo
```

After modyfing do:

```
cd /etc/postfix
postmap mailboxes
```

#### `relay-sasl`

The authentication credentials for relay hosts. Entries are of the form:

```
[smtp.google.net]:587 username:password
```

After modyfing do:

```
cd /etc/postfix
postmap relay-sasl
```

#### `master.cf`

The service definition file for postfix.

#### `main.cf`

- `hostname`: a string for greeting clients (e.g. `example.com`)
- `relayhost`: the relay destination (e.g. [smtp.sendgrid.net]:587)
- `virtual_mailbox_domains`: a space separated list of domains for receiving email (e.g. `example.com example1.com`)

### `/etc/dovecot/conf.d/↴`

#### `10-auth.conf`

Authentication processes.

#### `10-logging.conf`

Log destination.

#### `10-mail.conf`

Mailbox locations and namespaces.

#### `10-master.conf`

Services configuration (e.g. LMTP, IMAP, etc.).

#### `10-ssl.conf`

SSL settings.

#### `15-mailboxes.conf`

Mailbox definitions.

#### `20-lmtp.conf`

LMTP specific settings.

#### `90-plugin.conf`

Plugin settings.

#### `90-sieve.conf`

Settings for the Sieve interpreter.

#### `auth-passwdfile.conf.ext`

Authentication for passwd-file users.

### `/etc/dovecot/↴`

#### `dovecot.conf`

Configuration entry point for Dovecot.

#### `users`

Incoming mail SASL database. Format is comparable to that of `/etc/passwd` files.

### `/etc/dovecot/sieve/↴`

#### `default.sieve`

A sieve script to deliver spam email (marked by spamassassin) to the corresponding user mailbox (i.e. Junk).

## Migrating existing maildirs

Just copy the contents of the `cur` subdirectories in the source Mailbox to the target (do not forget to use `-p` to preserve timestamps and then `chown -R dovecot:dovecot` to fix user conflicts):

```bash
cp -p source/mailbox/.spam/cur/* target/mailbox/.Spam/cur
chown -R dovecot:dovecot target/mailbox
```

## Testing an SMTP with TLS session

Run `openssl` follows:

```
openssl s_client -starttls smtp -crlf -quiet -connect example.com:587
```

And, complete an `SMTP` session as follows:

```
HELO example1.com
250 example.com
MAIL FROM: <adam@example1.com>
250 2.1.0 Ok
RCPT TO: <bob@exmaple.com>
250 2.1.5 Ok
DATA
354 End data with <CR><LF>.<CR><LF>
From: Adam Doe <adam@example.com>
To: Bob Adams <bob@example1.com>
Subject: What is this?
It is an email, duh!
.
250 2.0.0 Ok: queued as 969DE121947
QUIT
221 2.0.0 Bye
```

## TODOs

- Use [cAdvisor](https://github.com/google/cadvisor) to monitor docker processes.
- Make postfix and dovecot logs show in the entrypoint process, instead of in files under `/var/log`.
- Make sieve deliver `+`-recipients (e.g. john+work@example.com) to corresponding mailboxes (i.e. Work in the example).
- Protect sender aliasing: https://serverfault.com/questions/797995/postfix-allow-sending-email-with-related-alias

## References

- [Nestor de Haro's post in Digital Ocean](https://www.digitalocean.com/community/tutorials/how-to-configure-a-mail-server-using-postfix-dovecot-mysql-and-spamassassin#-step-4-configure-dovecot)
- [Integrating SendGrid with postfix](https://sendgrid.com/docs/for-developers/sending-email/postfix/)
- [postfix docs](http://www.postfix.org/documentation.html)
- [Dovecot docs](https://doc.dovecot.org/)
- [Spamassassin tutorial](https://hostadvice.com/how-to/how-to-secure-postfix-with-spamassassin-on-an-ubuntu-18-04-vps-or-dedicated-server/)
