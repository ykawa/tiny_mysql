#!/bin/sh
set -eu
set -o pipefail

generate_keep_file_list() {
  # 削除対象外のファイル
  echo "
    etc/my.cnf
    usr/bin/my_print_defaults
    usr/bin/mysql
    usr/bin/mysql_install_db
    usr/bin/mysqld
    usr/share/mariadb/charsets/Index.xml
    usr/share/mariadb/charsets/README
    usr/share/mariadb/charsets/armscii8.xml
    usr/share/mariadb/charsets/ascii.xml
    usr/share/mariadb/charsets/cp1250.xml
    usr/share/mariadb/charsets/cp1251.xml
    usr/share/mariadb/charsets/cp1256.xml
    usr/share/mariadb/charsets/cp1257.xml
    usr/share/mariadb/charsets/cp850.xml
    usr/share/mariadb/charsets/cp852.xml
    usr/share/mariadb/charsets/cp866.xml
    usr/share/mariadb/charsets/dec8.xml
    usr/share/mariadb/charsets/geostd8.xml
    usr/share/mariadb/charsets/greek.xml
    usr/share/mariadb/charsets/hebrew.xml
    usr/share/mariadb/charsets/hp8.xml
    usr/share/mariadb/charsets/keybcs2.xml
    usr/share/mariadb/charsets/koi8r.xml
    usr/share/mariadb/charsets/koi8u.xml
    usr/share/mariadb/charsets/latin1.xml
    usr/share/mariadb/charsets/latin2.xml
    usr/share/mariadb/charsets/latin5.xml
    usr/share/mariadb/charsets/latin7.xml
    usr/share/mariadb/charsets/macce.xml
    usr/share/mariadb/charsets/macroman.xml
    usr/share/mariadb/charsets/swe7.xml
    usr/share/mariadb/english/errmsg.sys
    usr/share/mariadb/fill_help_tables.sql
    usr/share/mariadb/maria_add_gis_sp_bootstrap.sql
    usr/share/mariadb/mysql_performance_tables.sql
    usr/share/mariadb/mysql_system_tables.sql
    usr/share/mariadb/mysql_system_tables_data.sql
    usr/share/mariadb/mysql_test_db.sql
  " | sed -e 's/^\s*//g' -e '/^$/d'
}

# mariadbパッケージを追加する
apk add --no-cache mariadb mariadb-common

# 残すファイルの一覧を生成する（ashはプロセス置換ができないので一時ファイルに保存する）
generate_keep_file_list > /tmp/keep_file_list

# 不要なファイルを削除する
apk info -q -L mariadb mariadb-common linux-pam \
  | awk 'BEGIN{while((getline v<"/tmp/keep_file_list")>0){a[v]=1}}{if(!a[$0]){print $0}}' \
  | xargs rm -f

# linuxのdocker環境を考慮してmysqlユーザーのidを変更する
sed -i -e 's/mysql:x:[0-9]*:mysql/mysql:x:'${MY_GROUP_ID:-101}':mysql/' /etc/group
sed -i -e 's/mysql:x:[0-9]*:[0-9]*:/mysql:x:'${MY_USER_ID:-100}':'${MY_GROUP_ID:-101}':/' /etc/passwd

# 必須ファイル＆ディレクトリ作成と所有者の変更をする
mkdir -p /run/mysqld /var/lib/mysql
touch /usr/share/mariadb/mysql_test_db.sql
chown -R mysql:mysql /etc/my.cnf.d /run/mysqld /var/lib/mysql /usr/share/mariadb/mysql_system_tables_data.sql

# 不要なファイルを削除する
rm -rf /var/cache/* /var/log/* /var/tmp/* /tmp/*
mkdir -p /var/cache/apk

