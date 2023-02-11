FROM mariadb:10.3@sha256:e28e527b3b0268b6869d3143fc49379ae050184f3d0a15c4e5e9a8fab25d560d

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
