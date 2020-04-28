#!/usr/bin/env bash

function self_path() {
    echo "$PWD/${BASH_SOURCE[0]}";
}

BASE=$( dirname $( self_path ) );

docker build -t smtp . && \
docker container run \
  --network main \
  -p 993:993 \
  -p 25:25 \
  -p 465:25 \
  -p 587:25 \
  -v $BASE/var/log/dovecot.log:/var/log/dovecot.log \
  -v $BASE/var/log/postfix.log:/var/log/postfix.log \
  -v $BASE/var/mail/vhosts:/var/mail/vhosts \
  -d \
  --rm \
  --name smtp \
  smtp bash