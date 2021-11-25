#!/bin/sh
set -eo pipefail

generate_config() {
  echo "
  [mysqld]
  skip-networking = 0
  skip-bind-address
  skip-name-resolve
  skip-host-cache
  skip-slave-start
  skip-grant-tables
  skip-character-set-client-handshake

  [mariadb]
  innodb_buffer_pool_size = 10M
  innodb_log_buffer_size = 512K # default / 2
  innodb_log_file_size = 8M
  lower_case_table_names = 1
  key_buffer_size = 4194304 # default / 2
  " | sed -e 's/^\s*//' -e '1d'
}

# 初期状態ならmy.cnf を生成する
if [ -z "$(ls -A /etc/my.cnf.d/* 2>/dev/null)" ]; then
  echo "loading default config..."
  generate_config | tee /etc/my.cnf.d/my.cnf
fi

MYSQLD_OPTS="--user=mysql"
MYSQLD_OPTS="${MYSQLD_OPTS} --datadir=/var/lib/mysql"
MYSQLD_OPTS="${MYSQLD_OPTS} --debug-gdb" # signal or ctrl+c が使えるようにする

if [ -z "$(ls -A /var/lib/mysql/ 2>/dev/null)" ]; then
  echo "initialize /var/lib/mysql..."
  # /var/lib/mysql が初期化されていない場合
  INSTALL_OPTS=""
  INSTALL_OPTS="${INSTALL_OPTS} --user=mysql"
  INSTALL_OPTS="${INSTALL_OPTS} --datadir=/var/lib/mysql"
  INSTALL_OPTS="${INSTALL_OPTS} --cross-bootstrap"
  INSTALL_OPTS="${INSTALL_OPTS} --rpm"
  INSTALL_OPTS="${INSTALL_OPTS} --auth-root-authentication-method=normal"
  INSTALL_OPTS="${INSTALL_OPTS} --skip-test-db"
  eval /usr/bin/mysql_install_db "${INSTALL_OPTS}"

  # 初期化に使いたいSQLがある場合は /init.sql としてマウントする
  if [ -e /init.sql ]; then
    MYSQLD_OPTS="${MYSQLD_OPTS} --init-file=/init.sql"
  fi
fi

eval exec /usr/bin/mysqld "${MYSQLD_OPTS}"
