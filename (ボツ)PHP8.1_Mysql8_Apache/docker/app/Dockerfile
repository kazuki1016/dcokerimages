# どんな docker イメージを利用して構築をするか
# FROM : centosの最新版をダウンロード
FROM centos:7

# -------
# 変数定義
# -------
ARG document_dir="/var/www/html"
ARG php_version="81"
ARG laravel_version="8.*"

# OSのアップデートとサーバーに最低限必要なものと最新のPHPをダウンロードするためにepel-release、remiのレポジトリをインストール
RUN echo "OSのアップデートとミドルウェアのインストール"
RUN yum -y update && yum clean all
RUN yum -y install epel-release \
    http://rpms.remirepo.net/enterprise/remi-release-7.rpm \
    vim \
    httpd \
    git \
    zip \
    unzip \
    https://rpm.nodesource.com/pub_12.x/el/7/x86_64/nodesource-release-el7-1.noarch.rpm \
    nodejs

# PHPと拡張機能インストール
RUN echo "PHPと拡張機能インストール"
RUN yum -y install --enablerepo=remi,remi-php${php_version} \
    php \
    php-devel \
    php-mbstring \
    php-pdo \
    php-gd \
    php-xml \
    php-mcrypt \
    php-json \
    php-mysqlnd \
    php-common \
    php-cli \
    php-imap \
    php-opcache \
    npm install \
    npm run dev

RUN echo "php.ini、ドキュメントルートの設定ファイルを転送"
# 設定ファイルをdockerコンテナ内のPHP、Apacheに読み込ませる
COPY php.ini /usr/local/etc/php/
COPY default.conf /etc/httpd/conf.d/

# Apacheの起動
# centos7の公式イメージではsystemctlが使えない
ENTRYPOINT ["/usr/sbin/httpd", "-DFOREGROUND"]

# composerのダウンロード
RUN echo "composerのダウンロード"
RUN curl -sS https://getcomposer.org/installer | php
RUN mv composer.phar /usr/local/bin/composer

# WORKDIRを指定することで以降は指定したディレクトリで実施
WORKDIR $document_dir
