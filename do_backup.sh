#!/usr/bin/env bash

set -x

SCRIPT=$(readlink -f $0)
MYPATH=$(dirname $SCRIPT)

USER="routerbkp"
COMPACT=$(/bin/date +%Y%m%d_%H%M)
RFILE="${MYPATH}/routers.txt"
CONFDIR="${MYPATH}/configs"
SSHKEY="${MYPATH}/.ssh/id_rsa"

cd ${CONFDIR}

while read -r line; do

  ROUTER=$line
  echo Processing ${ROUTER}

  /usr/bin/ssh -n -i ${SSHKEY} -oStrictHostKeyChecking=no -oConnectTimeout=10 $USER@$ROUTER "/export file=export_${COMPACT}" &&
    /usr/bin/scp -i ${SSHKEY} -q $USER@$ROUTER:/export_${COMPACT}.rsc ${CONFDIR}/${ROUTER} &&
    /usr/bin/ssh -n -i ${SSHKEY} $USER@$ROUTER "/file remove export_${COMPACT}.rsc" &&
    sed -i -e "1d" ${CONFDIR}/${ROUTER}

done <"${RFILE}"

git add ${CONFDIR}
git commit -m "Autocommit"
