FROM postgres:13

# Copy Postgres config file into container
COPY postgresql.conf /etc/postgresql
COPY initdb.sh /docker-entrypoint-initdb.d/

RUN mkdir -p /var/lib/postgresql/archive && chown postgres:postgres /var/lib/postgresql/archive

# Override default Postgres config file
CMD ["postgres", "-c", "config_file=/etc/postgresql/postgresql.conf"]