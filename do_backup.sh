#!/usr/bin/env bash

set -e

source .env

COMPACT=$(/bin/date +%Y%m%d_%H%M)

eval $(ssh-agent -s)
echo "$PRIVATE_KEY" | ssh-add -
trap "ssh-agent -k" EXIT

cd ${CONFDIR}

while read -r line; do
  ROUTER="$(echo $line | cut -d':' -f1)"
  SSHPORT="$(echo "$line:" | cut -d':' -f2)"
  SSHPORT=${SSHPORT:-22}

  NEWROUTER="${USERONROUTER}@${ROUTER}"
  SSHCREDS="-p ${SSHPORT} ${NEWROUTER}"
  SCPCREDS="-P ${SSHPORT}"
  echo "Processing $NEWROUTER"

  /usr/bin/ssh -n -oStrictHostKeyChecking=no -oConnectTimeout=10 \
    ${SSHCREDS} "/export file=export_${COMPACT}" &&
    /usr/bin/scp ${SCPCREDS} -q ${NEWROUTER}:/export_${COMPACT}.rsc \
      ${CONFDIR}/${ROUTER} &&
    /usr/bin/ssh -n ${SSHCREDS} "/file remove export_${COMPACT}.rsc" &&
    sed -i.bak -e "1d" ${CONFDIR}/${ROUTER}

done <"${ROUTERS}"

rm "${CONFDIR}"/*.bak

git add ${CONFDIR}
git commit -m "Autocommit"
echo "SUCCESS"
