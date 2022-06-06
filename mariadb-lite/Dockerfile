FROM mariadb:10.8@sha256:c8f2b0c9a0143c2f86a25a92ad798342ba1235337adf69d5d30a8580249521fd

RUN \
    apt-get -qq update && \
    apt-get -qq install eatmydata && \
    eatmydata apt-get -qq upgrade && \
    rm -rf /var/lib/apt/lists/*

ENV \
    LD_PRELOAD=libeatmydata.so \
    MYSQL_ALLOW_EMPTY_PASSWORD=true \
    MYSQL_DATABASE=circle_test \
    MYSQL_HOST=127.0.0.1 \
    MYSQL_ROOT_HOST=% \
    MYSQL_USER=root

RUN \
    echo '\n[mysqld]\ncollation-server = utf8_unicode_ci\ninit-connect="SET NAMES utf8"\ncharacter-set-server = utf8\ninnodb_flush_log_at_trx_commit=2\nsync_binlog=0\ninnodb_use_native_aio=0\n' >> /etc/mysql/my.cnf && \
    echo '\n[mysqld]\ndatadir = /dev/shm/mysql\n' >> /etc/mysql/my.cnf
