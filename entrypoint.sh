#!/bin/bash

# Start dovecot
service dovecot start
status=$?
if [ $status -ne 0 ]; then
  echo "Failed to start dovecot: $status"
  exit $status
fi

# Start postfix
service postfix start
status=$?
if [ $status -ne 0 ]; then
  echo "Failed to start posfix: $status"
  exit $status
fi

# Start spamassassin
service spamassassin start
status=$?
if [ $status -ne 0 ]; then
  echo "Failed to start spamassassin: $status"
  exit $status
fi

while sleep 60; do
  ps aux | grep dovecot | grep -q -v grep
  PROCESS_1_STATUS=$?
  ps aux | grep postfix | grep -q -v grep
  PROCESS_2_STATUS=$?
  ps aux | grep postfix | grep -q -v grep
  PROCESS_3_STATUS=$?
  # If the greps above find anything, they exit with 0 status
  # If they are not both 0, then something is wrong
  if [ $PROCESS_1_STATUS -ne 0 -o $PROCESS_2_STATUS -ne 0 -o $PROCESS_3_STATUS -ne 0 ]; then
    echo "One of the processes has already exited."
    exit 1
  fi
done