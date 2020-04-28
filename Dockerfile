FROM debian:latest
LABEL maintainer="jon@than.ml"

ENV DEBIAN_FRONTEND=noninteractive
RUN echo "postfix postfix/main_mailer_type string No configuration" | debconf-set-selections

# Install software
RUN apt-get update
RUN apt-get install -y procps postfix dovecot-core dovecot-imapd dovecot-lmtpd

# Configurations
COPY etc /etc

# Run postfix utilities
WORKDIR /etc/postfix
RUN ls
RUN postmap aliases
RUN postmap mailboxes
RUN postmap sasl_passwd
WORKDIR /

COPY entrypoint.sh /
ENTRYPOINT [ "./entrypoint.sh" ]
