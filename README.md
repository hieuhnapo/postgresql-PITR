docker exec -it postgresql_13 bash

# create base backup
mkdir -p /var/lib/postgresql/backup
pg_basebackup -D /var/lib/postgresql/backup -U postgres -h localhost -p 5432

ls /var/lib/postgresql/backup
exit


# create sample data 
docker exec -it postgresql_13 bash
psql -U postgres -d freight_forwarder

CREATE TABLE freight_forwarder_18.cars (
  brand VARCHAR(255),
  model VARCHAR(255)
);
INSERT INTO freight_forwarder_18.cars (brand, model) VALUES ('A', 'A');
INSERT INTO freight_forwarder_18.cars (brand, model) VALUES ('A', 'B');
INSERT INTO freight_forwarder_18.cars (brand, model) VALUES ('C', 'C');

# wait a minutes

DELETE FROM freight_forwarder_18.cars;
exit


# restore command

docker stop postgresql_13

# get directory of mount folder
docker inspect postgresql_13 | grep -i "Source"

mv /var/lib/docker/volumes/postgresql_pgdata/_data /var/lib/docker/volumes/postgresql_pgdata/_data_old

mkdir -p /var/lib/docker/volumes/postgresql_pgdata/_data
chmod 700 /var/lib/docker/volumes/postgresql_pgdata/_data

cp -a /var/lib/docker/volumes/postgresql_pgbackup/_data/. /var/lib/docker/volumes/postgresql_pgdata/_data/

rm -rf /var/lib/docker/volumes/postgresql_pgdata/_data/pg_wal

cp -a /var/lib/docker/volumes/postgresql_pgdata/_data_old/pg_wal/. /var/lib/docker/volumes/postgresql_pgdata/_data/pg_wal/

cp -a /var/lib/docker/volumes/postgresql_pgarchive/_data/. /var/lib/docker/volumes/postgresql_pgdata/_data/pg_wal/

rm -rf /var/lib/docker/volumes/postgresql_pgdata/_data_old

touch /var/lib/docker/volumes/postgresql_pgdata/_data/recovery.signal

# add config restore
vi postgresql.conf

# modify config
restore_command = 'cp /var/lib/postgresql/archive/%f "%p"'
recovery_target_time = '2024-07-30 10:41:00'

docker compose build
docker compose up -d

docker exec -it postgresql_13 bash
psql -U postgres -d freight_forwarder
SELECT pg_promote();
SELECT pg_is_in_recovery();

# reset
# docker compose down
# docker volume rm postgresql_pgarchive
# docker volume rm postgresql_pgbackup
# docker volume rm postgresql_pgdata

# docker compose build
# docker compose up -d

# docker exec -t postgres pg_dump -U postgres -d freight_forwarder | docker exec -i postgresql_13 psql -U postgres -d freight_forwarder
# docker exec -t postgres pg_dump -U postgres -d master | docker exec -i postgresql_13 psql -U postgres -d master
