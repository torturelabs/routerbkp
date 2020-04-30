#!/usr/bin/env bash

NEWROUTER="admin@10.10.247.228"

NEW_UUID=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)

ssh ${NEWROUTER} "/user add name=routerbkp group=full password=$NEW_UUID"

scp .ssh/id_rsa.pub ${NEWROUTER}:/routerbkp.pub

ssh ${NEWROUTER} "/user ssh-keys import public-key-file=routerbkp.pub user=routerbkp"
