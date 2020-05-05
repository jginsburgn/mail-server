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

### `/etc/postfix/`

#### `main.cf`

- `hostname`: a string for greeting clients (e.g. `example.com`)
- `relayhost`: the relay destination (e.g. [smtp.sendgrid.net]:587)
- `virtual_mailbox_domains`: a space separated list of domains for receiving email (e.g. `example.com example1.com`)

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

### `/etc/dovecot/conf.d/10-mail.conf`

### `/etc/dovecot/conf.d/10-master.conf`

### `/etc/dovecot/conf.d/10-logging.conf`

### `/etc/dovecot/conf.d/10-auth.conf`

### `/etc/dovecot/conf.d/10-ssl.conf`

### `/etc/dovecot/conf.d/auth-passwdfile.conf.ext`

### `/etc/dovecot/dovecot.conf`

## Migrating existing maildirs

Just copy the contents of the `cur` subdirectories in the source Mailbox to the target (do not forget to use `-p` to preserve timestamps and then `chown -R dovecot:dovecot` to fix user conflicts):

```bash
cp -p source/mailbox/.spam/cur/* target/mailbox/.Spam/cur
chown -R dovecot:dovecot target/mailbox
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
