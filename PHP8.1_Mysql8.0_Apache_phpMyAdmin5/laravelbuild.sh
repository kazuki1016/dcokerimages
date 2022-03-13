#!/bin/bash
# ------------------------------------------------------------------
# シェル名：laravelbuild.sh-------------------------------------------
# 使用方法：sh laravelbuild.sh 引数
# 引数：「new」もしくは「gitclone」のみ使用可能。それ以外は即時終了させる
# ------------------------------------------------------------------

if [ $1 != "new" ] && [ $1 != "gitclone" ]; then
	echo "引数が正しくありません。スクリプトを終了します"
	exit
fi

if [ $1 = "new" ]; then
	echo "新規プロジェクトです"
	exit
elif [ $1 = "gitclone" ]; then
	echo "gitHubからダウンロードします"
	exit
fi

# --------------------
# ------変数定義-------
# --------------------
# ドキュメントルートの指定
DOCUMENT_ROOT=/var/www/html
# Laravelのプロジェクト名
PROJECT_NAME=
# Laravelのバージョンの指定
LARAVEL_VERSION=8.*
# gitcloneするディレクトリの指定
GITCLONEDIR=
# git cloneのリポジトリ名の指定
GITCLONEREPOGITRY=

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

if [ $1="new" ]; then
	echo "＜step1＞Laravelのインストール。Laravlのバージョン：${LARAVEL_VERSION}"
	docker-compose exec app composer create-project laravel/laravel $PROJECT_NAME "${LARAVEL_VERSION}"
else
	echo "＜step1＞git cloneの実行とcomposer inatallの実行"
	cd $GITCLONEDIR
	git clone $GITCLONEREPOGITRY $PROJECT_NAME
	docker-compose exec app composer install
fi

echo "＜step2＞権限の変更"
docker-compose exec app bash -c "cd ; chmod -R 777 ${DOCUMENT_ROOT}/${PROJECT_NAME}/storage; chmod -R 777 ${DOCUMENT_ROOT}/${PROJECT_NAME}/bootstrap/cache/"

# 先にインストールしておかないと以降のartisanコマンドが全てエラーになる。
echo "＜step3＞デバックバーをインストール"
docker-compose exec app bash -c " cd ${DOCUMENT_ROOT}/${PROJECT_NAME}; composer require barryvdh/laravel-debugbar"

if [ $1="new" ]; then
	echo "＜step4＞Laravel初期設定ファイルをappコンテナへ転送"
	# docker cp {ホスト側ファイルパス} {コンテナ名}:{docker内のパス}
	docker cp ./docker/app/laravelfiles/config ${CONTAINER_NAME}:${DOCUMENT_ROOT}/${PROJECT_NAME}
	docker cp ./docker/app/laravelfiles/.env ${CONTAINER_NAME}:${DOCUMENT_ROOT}/${PROJECT_NAME}
	docker cp ./docker/app/laravelfiles/ja ${CONTAINER_NAME}:${DOCUMENT_ROOT}/${PROJECT_NAME}/resources/lang
	docker cp ./docker/app/laravelfiles/ja.json ${CONTAINER_NAME}:${DOCUMENT_ROOT}/${PROJECT_NAME}/resources/lang
	docker cp ./docker/app/laravelfiles/seeders ${CONTAINER_NAME}:${DOCUMENT_ROOT}/${PROJECT_NAME}/database
else
	docker cp ./docker/app/laravelfiles/.env ${CONTAINER_NAME}:${DOCUMENT_ROOT}/${PROJECT_NAME}
fi

echo "＜step5＞key生成"
docker-compose exec app bash -c " cd ${DOCUMENT_ROOT}/${PROJECT_NAME}; php artisan key:generate"
# docker-compose exec app bash -c " cd ${DOCUMENT_ROOT}/${PROJECT_NAME}; php artisan config:clear"

echo "＜step6＞migrateの実行"
docker-compose exec app bash -c " cd ${DOCUMENT_ROOT}/${PROJECT_NAME}; php artisan migrate"



if [ $1="new" ]; then
	echo "＜step7＞Laravel Breezeをインストールの実行"
	docker-compose exec app bash -c " cd ${DOCUMENT_ROOT}/${PROJECT_NAME}; composer require laravel/breeze --dev"

	echo "＜step8＞認証ビュー、ルート、コントローラ、およびその他のリソースをアプリケーションにリソース公開"
	docker-compose exec app bash -c " cd ${DOCUMENT_ROOT}/${PROJECT_NAME}; php artisan breeze:install"

	echo "＜step9＞フロントエンドに必要なパッケージをインストール"
	docker-compose exec app bash -c " cd ${DOCUMENT_ROOT}/${PROJECT_NAME}; npm install; npm run dev"

	echo "＜step10＞publicフォルダにstorageフォルダへのリンクを貼る"
	docker-compose exec app bash -c " cd ${DOCUMENT_ROOT}/${PROJECT_NAME}; php artisan storage:link"

	echo "＜step11＞UserSeedの実行"
	docker-compose exec app bash -c " cd ${DOCUMENT_ROOT}/${PROJECT_NAME}; php artisan db:seed"
fi
