# dockerで新規プロジェクトを作成する際にやること

## インストール
- Laravel_Project以下に任意のプロジェクト名でフォルダを作成。その後、docker_sampleフォルダ以下をコピーしてくる
- docker/app/000-default.confのドキュメントルート/var/www/html/〇〇/publicのところとDirectory/var/www/html/〇〇/publicを任意のプロジェクト名に変える
- docker-compose.ymlのコンテナ名を任意に変更
- docker-compose buildコマンドでdocker imageのビルド
- docker-compose up -dでコンテナの立ち上げ
- docker-compose exec app bashでコンテナに入る
- composer create-project --prefer-dist laravel/laravel プロジェクト名 “バージョン”でプロジェクトの作成
- docker-compose.ymlのDB情報を元に.envファイルの修正。DB_HOSTはコンテナ名にする
- メール機能を使う場合、.envファイルの「MAIL_FROM_ADDRESS」、「MAIL_FROM_NAME」=を任意に設定
- chmod -R 777 storage bootstrap/cacheで権限を変えてサーバーからの書き込みを許可する
- docker-compose exec app bashでコンテナに入ってプロジェクトフォルダに入り、php artisan make migrateでテーブルが作成できることを確認

## 認証機能の実装とフロントエンド周りの開発環境のインストール(Laravel6、breezeの場合)
- composer require laravel/ui:^1.0 --devでlaravel/uiライブラリ（認証機能の雛形）をインストール（バージョンを指定しないと最新版がインストールされて互換性がなくなってエラーになるので注意）
- php artisan ui vue --authでログイン機能のインストール
- npm installでフロントエンドに必要なパッケージをインストール
- npm run devでCSS/JSを作成、ビルド

## 認証機能の実装とフロントエンド周りの開発環境のインストール( Laravel8、breezeの場合)
- 先にphp artisan migrateで認証周りのテーブル作成
- composer require laravel/breeze --devでLaravel Breezeをインストール
- php artisan breeze:installで認証ビュー、ルート、コントローラ、およびその他のリソースをアプリケーションにリソース公開する。
- npm installでフロントエンドに必要なパッケージをインストール
- npm run devでCSS/JSを作成、ビルド


## Laravelデバックバーのインストール
- composer require barryvdh/laravel-debugbarでインストール
- .envのLOG_CHANNELを修正
(以後、.envファイルを修正したらphp artisan config:cacheを実行する)

```.env
LOG_CHANNEL=daily
```

- /config/app.phpに以下を追加<br>
サービスプロバイダーの項目にデバックバー「Barryvdh\Debugbar\ServiceProvider::class,」を追記<br>
Class Aliasesの項目に「Debugbar' => Barryvdh\Debugbar\Facade::class,」を追記<br>
.envファイル の APP_DEBUG の定数をtrueにする<br>

## 日本語化の設定
/config/app.phpの以下の箇所を修正

```php
    /*
    |--------------------------------------------------------------------------
    | Application Timezone
    |--------------------------------------------------------------------------
    |
    | Here you may specify the default timezone for your application, which
    | will be used by the PHP date and date-time functions. We have gone
    | ahead and set this to a sensible default for you out of the box.
    |
    */
	//timezoneを'Asia/Tokyo'へ
    'timezone' => 'Asia/Tokyo',

    /*
    |--------------------------------------------------------------------------
    | Application Locale Configuration
    |--------------------------------------------------------------------------
    |
    | The application locale determines the default locale that will be used
    | by the translation service provider. You are free to set this value
    | to any of the locales which will be supported by the application.
    |
    */
	//ロケールをjaへ
    'locale' => 'ja',
```
他にもバリデーションなどを日本語化するために以下コマンド実行

```sh
# 6.xの部分はバージョンに合わせる
php -r "copy('https://readouble.com/laravel/6.x/ja/install-ja-lang-files.php', 'install-ja-lang.php');"
php -f install-ja-lang.php
php -r "unlink('install-ja-lang.php');"
composer require Laravel-Lang/lang
```

s/resources/lang/ja.json_ja.jsonで上記以外の箇所も日本語化する

```ja,json
{
    "Login": "ログイン",
    "Register": "新規登録",
    "Forgot Your Password?": "パスワードを忘れた場合",
    "Reset Password": "パスワード再設定",
    "Send Password Reset Link": "パスワード再設定URLを送信",
    "Name": "お名前",
    "E-Mail Address": "メールアドレス",
    "Password": "パスワード",
    "Confirm Password": "パスワード(確認用)",
    "Remember Me": "ログイン状態を保存",
    "Hello!": "ご利用ありがとうございます。",
    "Reset Password Notification": "パスワード再設定のお知らせ",
    "You are receiving this email because we received a password reset request for your account.": "あなたのアカウントでパスワード再発行のリクエストがありました。",
    "This password reset link will expire in :count minutes.": "再設定URLの有効期限は :count 分です。",
    "If you did not request a password reset, no further action is required.": "もしパスワード再発行をリクエストしていない場合、操作は不要です。",
    "If you’re having trouble clicking the \":actionText\" button, copy and paste the URL below\ninto your web browser: [:actionURL](:actionURL)": "\":actionText\"ボタンを押しても何も起きない場合、以下URLをコピーしてWebブラウザに貼り付けてください。\n[:actionURL](:actionURL)",
    "Regards": "よろしくお願いいたします"
}
```
