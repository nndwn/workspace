#!/bin/bash
set -e  # Stop jika ada error

if [ ! -s "/var/lib/postgresql/data/PG_VERSION" ]; then
    echo "🔹 Inisialisasi database baru..."
    gosu postgres initdb

    if [ "$PWD_DB" ]; then
        pass="PASSWORD '$PWD_DB'"
        authMethod=md5
    else
        pass=""
        authMethod=trust
    fi
    echo "🔹 Konfigurasi autentikasi: $authMethod"
    echo "host all all 0.0.0.0/0 $authMethod" >> /var/lib/postgresql/data/pg_hba.conf

    gosu postgres pg_ctl -D /var/lib/postgresql/data -o "-c listen_addresses='localhost'" -w start

    gosu postgres psql -c "CREATE USER $USER_DB WITH SUPERUSER $pass;"
    gosu postgres psql -c "CREATE DATABASE $PG_DB OWNER $USER_DB;"

    echo "🔹 Menjalankan skrip tambahan..."
    for f in /docker-entrypoint-initdb.d/*; do
        case "$f" in
            *.sh)  echo "Menjalankan script $f"; . "$f" ;;
            *.sql) echo "Menjalankan SQL $f"; gosu postgres psql < "$f"; ;;
            *.sql.gz) echo "Menjalankan SQL gzip $f"; gunzip -c "$f" | gosu postgres psql ;;
            *) echo "Mengabaikan file: $f" ;;
        esac
    done

    gosu postgres pg_ctl -D /var/lib/postgresql/data -m fast -w stop
    echo "✅ Inisialisasi selesai! Database siap digunakan."
fi

exec gosu postgres postgres
