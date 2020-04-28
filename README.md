# SMTP Server in a Docker Image

This image combines postfix and dovecot into a secure IMAP/SMTP server. The server is enabled with virtual users, each with its own maildir.

## Postfix

Postfix is the main workhorse for receiving mail through SMTP and delivering it locally (LMTP) or remotely (SMTP).

## Dovecot

Dovecot serves postfix to:

- authenticate SMTP users via SASL
- write local delivery email to maildirs
- serve maildirs via IMAP

## TLS

All exposed services in this image rely on TLS. Therefore, a certificate in PEM format and its key should be located at `etc/ssl/certs/ssl-cert-snakeoil.pem` and `/etc/ssl/private/ssl-cert-snakeoil.key`, respectively.

## Relevant Configurations

After a modification to one of the files do: `service dovecot restart` or `service postfix restart` as needed. Most relevant configuration files are:

### `/etc/postfix/main.cf`

### `/etc/dovecot/conf.d/10-mail.conf`

### `/etc/dovecot/conf.d/10-master.conf`

### `/etc/dovecot/conf.d/10-logging.conf`

### `/etc/dovecot/conf.d/10-auth.conf`

### `/etc/dovecot/conf.d/10-ssl.conf`

### `/etc/dovecot/conf.d/auth-passwdfile.conf.ext`

### `/etc/dovecot/dovecot.conf`

## Migrating existing maildirs

First `gunzip` all files in the old maildir (or add Zlib plugin to dovecot; see TODOs). Then make sure that the file name of each SMTP mail reflects the correct mail size. Then run: `doveadm import -u "destination email" "maildir:/maildir/location" "" all`

## TODOs

- Use [cAdvisor](https://github.com/google/cadvisor) to monitor docker processes.
- Make postfix and dovecot logs show in the entrypoint process, instead of in files under `/var/log`.
- Add Zlib plugin to dovecot.

## References

- [Nestor de Haro's post in Digital Ocean](https://www.digitalocean.com/community/tutorials/how-to-configure-a-mail-server-using-postfix-dovecot-mysql-and-spamassassin#-step-4-configure-dovecot)
- [Integrating SendGrid with postfix](https://sendgrid.com/docs/for-developers/sending-email/postfix/)
- [postfix docs](http://www.postfix.org/documentation.html)
- [Dovecot docs](https://doc.dovecot.org/)
- [Spamassassin tutorial](https://hostadvice.com/how-to/how-to-secure-postfix-with-spamassassin-on-an-ubuntu-18-04-vps-or-dedicated-server/)
