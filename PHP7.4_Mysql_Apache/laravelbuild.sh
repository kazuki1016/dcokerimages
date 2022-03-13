#!/bin/bash

# --------------------
# ------変数定義-------
# --------------------
# ドキュメントルートの設定
DOCUMENT_ROOT=/var/www/html
# Laravelのプロジェクト名
PROJECT_NAME=dockerpractice
# Laravelのバージョン
LARAVEL_VERSION=8.*

# .envファイルに上書きする情報
# DB情報
DB_HOST=test_db
DB_PORT=test-db-container
DB_DATABASE=test_db
DB_USERNAME=test_user
DB_PASSWORD=test_pass

# ログチャンネル
LOG_CHANNEL=daily

# メール設定
MAIL_HOST=smtp.gmail.com
MAIL_PORT=465
MAIL_USERNAME=sktyu09s3034t@gmail.com
MAIL_PASSWORD=tcibrqpesrorjnzb
MAIL_ENCRYPTION=ssl
MAIL_FROM_ADDRESS=sktyu09s3034t@gmail.com
MAIL_FROM_NAME="${APP_NAME}"

# ----------------------------------
# --docker-compose実施スクリプト------
# ----------------------------------
echo "コンテナの作成"
docker-compose build

echo "コンテナの起動"
docker-compose up -d

# ----------------------------------
# --Laravelプロジェクト作成スクリプト---
# ----------------------------------

echo "＜step1＞Laravelのインストール。Laravlのバージョン：${LARAVEL_VERSION}"
docker-compose exec app composer create-project laravel/laravel $PROJECT_NAME "${LARABEL_VERSSION}"

echo "＜step2＞権限の変更"
docker-compose exec app bash -c "cd ; chmod -R 777 ${DOCUMENT_ROOT}/${PROJECT_NAME}/storage; chmod -R 777 ${DOCUMENT_ROOT}/${PROJECT_NAME}/bootstrap/cache/"

echo "＜step3＞設定ファイルの書き換え"
# docker cp {ホスト側ファイルパス} {コンテナ名}:{docker内のパス}
docker cp .docker/larabelfiles/config app:${DOCUMENT_ROOT}/${PROJECT_NAME}
docker cp .docker/larabelfiles/.env app:${DOCUMENT_ROOT}/${PROJECT_NAME}

# sed -i（置換後上書き） -e（置換パターン）で
# echo "＜step3＞.envの書き換え（DB設定）"
# docker-compose app bash -c "sed -i -e \"s/DB_HOST=/DB_HOST=${DB_HOST}/g\" ${DOCUMENT_ROOT}/${PROJECT_NAME}.env"
# docker-compose app bash -c "sed -i -e \"s/DB_PORT=/DB_PORT=${DB_PORT}/g\" ${DOCUMENT_ROOT}/${PROJECT_NAME}.env"
# docker-compose app bash -c "sed -i -e \"s/DB_DATABASE=/DB_DATABASE=${DB_DATABASE}/g\" ${DOCUMENT_ROOT}/${PROJECT_NAME}.env"
# docker-compose app bash -c "sed -i -e \"s/DB_USERNAME=/DB_USERNAME=${DB_USERNAME}/g\" ${DOCUMENT_ROOT}/${PROJECT_NAME}.env"
# docker-compose app bash -c "sed -i -e \"s/DB_PASSWORD=/DB_PASSWORD=${DB_PASSWORD}/g\" ${DOCUMENT_ROOT}/${PROJECT_NAME}.env"

# echo "＜step3＞.envの書き換え（メール設定）"
# docker-compose app bash -c "sed -i -e \"s/MAIL_HOST=/MAIL_HOST=${MAIL_HOST}/g\" ${DOCUMENT_ROOT}/${PROJECT_NAME}.env"
# docker-compose app bash -c "sed -i -e \"s/MAIL_PORT=/MAIL_PORT=${MAIL_PORT}/g\" ${DOCUMENT_ROOT}/${PROJECT_NAME}.env"
# docker-compose app bash -c "sed -i -e \"s/MAIL_USERNAME=/MAIL_USERNAME=${MAIL_USERNAME}/g\" ${DOCUMENT_ROOT}/${PROJECT_NAME}.env"
# docker-compose app bash -c "sed -i -e \"s/MAIL_ENCRYPTION=/MAIL_ENCRYPTION=${MAIL_ENCRYPTION}/g\" ${DOCUMENT_ROOT}/${PROJECT_NAME}.env"
# docker-compose app bash -c "sed -i -e \"s/MAIL_FROM_ADDRESS=/MAIL_FROM_ADDRESS=${MAIL_FROM_ADDRESS}/g\" ${DOCUMENT_ROOT}/${PROJECT_NAME}.env"
# docker-compose app bash -c "sed -i -e \"s/MAIL_FROM_NAME=/MAIL_FROM_NAME=${MAIL_FROM_NAME}/g\" ${DOCUMENT_ROOT}/${PROJECT_NAME}.env"

echo "＜step4＞key生成"
docker-compose exec app bash -c " cd ${DOCUMENT_ROOT}/${PROJECT_NAME}; php artisan key:generate"

echo "＜step5＞migrateの実行"
docker-compose exec app bash -c " cd ${DOCUMENT_ROOT}/${PROJECT_NAME}; php artisan migrate"

echo "＜step6＞Laravel Breezeをインストールの実行"
docker-compose exec app bash -c " cd ${DOCUMENT_ROOT}/${PROJECT_NAME}; composer require laravel/breeze --dev"

echo "＜step7＞認証ビュー、ルート、コントローラ、およびその他のリソースをアプリケーションにリソース公開"
docker-compose exec app bash -c " cd ${DOCUMENT_ROOT}/${PROJECT_NAME}; php artisan breeze:install"

echo "＜step8＞フロントエンドに必要なパッケージをインストール"
docker-compose exec app bash -c " cd ${DOCUMENT_ROOT}/${PROJECT_NAME}; npm install; npm run dev"
