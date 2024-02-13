#!/bin/bash
set -e

## Participants DB initialization
for db in ${participants}
do
  psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" -c "CREATE DATABASE $db"
  psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$db" -a -f /docker-entrypoint-initdb.d/db_bootstrap_script.sql
done