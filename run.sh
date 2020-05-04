#!/usr/bin/env bash

function self_path() {
    echo "$PWD/${BASH_SOURCE[0]}";
}

BASE=$( dirname $( self_path ) );

docker build -t smtp . && \
echo "" | tee $BASE/var/log/{dovecot,postfix,spamassassin}.log >/dev/null && \
docker container run \
  --network main \
  -p 993:993 \
  -p 25:25 \
  -p 465:25 \
  -p 587:25 \
  -v $BASE/var/log/dovecot.log:/var/log/dovecot.log \
  -v $BASE/var/log/postfix.log:/var/log/postfix.log \
  -v $BASE/var/log/spamassassin.log:/var/log/spamassassin.log \
  -v $BASE/var/mail/vhosts:/var/mail/vhosts \
  -v /etc/localtime:/etc/localtime:ro \
  -v /etc/timezone:/etc/timezone:ro \
  -d \
  --rm \
  --name smtp \
  smtp bash
