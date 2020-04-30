#!/usr/bin/env bash

set -x
set -e

source .env

# Return the canonicalized path (works on OS-X like 'readlink -f' on Linux); . is $PWD
function realpath {
    [ "." = "${1}" ] && n=${PWD} || n=${1}; while nn=$( readlink -n "$n" ); do n=$nn; done; echo "$n"
}

COMPACT=$(/bin/date +%Y%m%d_%H%M)
SSHKEY="${MYPATH}/.ssh/id_rsa"

cd ${CONFDIR}

while read -r line; do

  ROUTER=$line
  echo Processing ${ROUTER}

  /usr/bin/ssh -n -i ${SSHKEY} -oStrictHostKeyChecking=no -oConnectTimeout=10 $USERONROUTER@$ROUTER "/export file=export_${COMPACT}" &&
    /usr/bin/scp -i ${SSHKEY} -q $USERONROUTER@$ROUTER:/export_${COMPACT}.rsc ${CONFDIR}/${ROUTER} &&
    /usr/bin/ssh -n -i ${SSHKEY} $USERONROUTER@$ROUTER "/file remove export_${COMPACT}.rsc" &&
    sed -i -e "1d" ${CONFDIR}/${ROUTER}

done <"${ROUTERS}"

git add ${CONFDIR}
git commit -m "Autocommit"
