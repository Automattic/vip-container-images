FROM mariadb:10.3@sha256:5157cee1d3297142bbcd7798787395086b3c1bd2f424362a02a022f203d1c944

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
    echo '\n[mysqld]\ncollation-server = utf8_unicode_ci\ninit-connect="SET NAMES utf8"\ncharacter-set-server = utf8\ninnodb_flush_log_at_trx_commit=2\nsync_binlog=0\ninnodb_use_native_aio=0\n' >> /etc/mysql/my.cnf
#    echo '\n[mysqld]\ndatadir = /dev/shm/mysql\ninnodb_flush_method = 3\n' >> /etc/mysql/my.cnf
