#!/bin/bash

RUNONCEFLAG=/var/lock/bootstrap.lock
if [ -e $RUNONCEFLAG ]; then
  exit 0
fi
apt-get update
touch ${RUNONCEFLAG}