#!/bin/bash

###
# It's important make a trusted ssh key between local and remote server.
#
DATE=$(date +"%Y-%m-%d")
IP_DESTIONATION="192.168.100.10"
REMOTE_FOLDER="/home/backup/logical/"
RETENTION_TIME="+30"

SQL_GETLIST="select datname from pg_database where datname not in ('template0') order by datname;"

ssh root@${IP_DESTIONATION} "cd ${REMOTE_FOLDER} && find . -mtime ${RETENTION_TIME} -type f -delete"

for db in $(psql -U postgres -t -c "${SQL_GETLIST}");
do
  echo "Exporting database: $db..."
  pg_dump -U postgres -Fc -d ${db} | ssh -c arcfour root@${IP_DESTIONATION} "cat > ${REMOTE_FOLDER}/${db}_${DATE}.dump"
done
