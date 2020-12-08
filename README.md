# SUPER TINY MYSQL SERVER

自分用超軽量 mysql server


## 使い方

ビルド方法

```console
$ docker build -t tiny_mysql .
```


起動方法 データ永続化不要時

```console
$ docker run --name db -it --rm --init -p 3306:3306 tiny_mysql
```


起動方法 データ永続化時（カレントディレクトリ my_data に保存）

```console
$ docker run --name db -it --rm --init -v $(pwd -P)/my_data:/var/lib/mysql -p 3306:3306 tiny_mysql
```


起動方法 データ永続化時（volume 配下に保存）

```console
$ docker volume create db
$ docker run --name db -it --rm --init -v db:/var/lib/mysql -p 3306:3306 tiny_mysql
```


起動方法 設定ファイル指定（/etc/my.cnf.d/配下に cnfファイルをマウントする）

```console
$ docker run --name db -it --rm --init -v $(pwd)/my.cnf:/etc/my.cnf.d/my.cnf -p 3306:3306 tiny_mysql
```


起動方法 初期実行SQL指定（/init.sql にマウントする）

```console
$ docker run --name db -it --rm --init -v $(pwd)/data.sql:/init.sql -p 3306:3306 tiny_mysql
```
