#!/usr/bin/env bash

set -e

source .env

ADMIN=${ADMIN:-admin}

NEW_UUID=$(cat /dev/urandom | LC_ALL=C tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)

while read -r line; do
  ROUTER="$(echo $line | cut -d':' -f1)"
  SSHPORT="$(echo "$line:" | cut -d':' -f2)"
  SSHPORT=${SSHPORT:-22}

  NEWROUTER="${ADMIN}@${ROUTER}"
  SSHCREDS="-p ${SSHPORT} ${NEWROUTER}"
  SCPCREDS="-P ${SSHPORT}"
  echo "Checking $NEWROUTER"

  USRONROUT=`ssh ${SSHCREDS} ":put [/user find name=routerbkp]"`
  if [[ -z "$USRONROUT" ]]; then
    # Add new user to router
    ssh ${SSHCREDS} "/user add name=${USERONROUTER} group=full password=$NEW_UUID"
    echo "User ${USERONROUTER} was added to ${ROUTER}"
  fi

  scp ${SCPCREDS} ${PUBKEY} ${NEWROUTER}:/routerbkp.pub
  ssh ${SSHCREDS} "/user ssh-keys import public-key-file=routerbkp.pub user=routerbkp"

done \
  <"${ROUTERS}"
exit

echo "SUCCESS"
