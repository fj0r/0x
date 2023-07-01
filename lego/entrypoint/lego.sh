#!/usr/bin/env bash
set -e

domain_args=""
IFS=',' read -ra DM <<< "${DOMAINS}"
for d in ${DM[@]}; do
    domain_args+=" --domains=${d}"
done

lego -a --email="${EMAIL}" $domain_args --http --path /data run 2>&1
opwd=$PWD
cd /data
cp -f certificates/${DM[0]}.key .
cp -f certificates/${DM[0]}.crt .
cd $opwd
