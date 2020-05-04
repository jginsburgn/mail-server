FROM debian:latest
LABEL maintainer="jon@than.ml"

ENV DEBIAN_FRONTEND=noninteractive
RUN echo "postfix postfix/main_mailer_type string No configuration" | debconf-set-selections

# Install software
RUN apt-get update
RUN apt-get install -y procps
RUN apt-get install -y postfix
RUN apt-get install -y dovecot-core
RUN apt-get install -y dovecot-imapd
RUN apt-get install -y dovecot-lmtpd
RUN apt-get install -y spamassassin
RUN apt-get install -y spamc
RUN apt-get install -y dovecot-sieve

# Configurations
COPY etc /etc

# Permissions for sieve
RUN chown -R dovecot:dovecot /etc/dovecot/sieve

# Run postfix utilities
WORKDIR /etc/postfix
RUN postmap aliases
RUN postmap mailboxes
RUN postmap sasl_passwd
WORKDIR /

COPY entrypoint.sh /
ENTRYPOINT [ "./entrypoint.sh" ]
