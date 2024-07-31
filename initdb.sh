#!/bin/bash
set -e

# Check if database 'freight_forwarder' exists
psql -U "$POSTGRES_USER" -tc "SELECT 1 FROM pg_database WHERE datname = 'freight_forwarder'" | grep -q 1 || psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" <<-EOSQL
    CREATE DATABASE freight_forwarder;
EOSQL

# Check if database 'master' exists
psql -U "$POSTGRES_USER" -tc "SELECT 1 FROM pg_database WHERE datname = 'master'" | grep -q 1 || psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" <<-EOSQL
    CREATE DATABASE master;
EOSQL

# Switch WAL
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" -c "SELECT pg_switch_wal();"
