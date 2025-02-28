## 概要
OpenID Connect で認証を行い、リソースサーバーから情報を取得するまでの一連の流れを確認できます

使用gem
- devise
- doorkeeper
- doorkeeper_openid_connect

## 初期設定
docker を起動してください。
起動時にシードデータとしてユーザーが作成されます
```
docker compose up
```





## 動作確認

![image](https://github.com/user-attachments/assets/532f481f-ffa6-4d32-be3e-3e2f5a78d796)


https://authya.booth.pm/items/1550861より引用

### 前準備 クライアントの登録
サーバー側であらかじめクライアントを登録します。ここで設定したuid, secret, redirect_uri は後でリクエストを送る際に使います
```ruby
$ docker compose exec doorkeeper_rails bash

$ Doorkeeper::Application.create!(
name: 'test_app',
uid: 'test_uid',
secret: 'test_secret',
redirect_uri: 'urn:ietf:wg:oauth:2.0:oob', # 本来はクライアントアプリのuriを設定するが、テスト用にこの値を設定する
scopes: 'read openid', # openidを使いたい場合はスコープに追加が必要
confidential: true,
)
```

### 1. 認可コードの発行（図の3から9）
Ref. https://github.com/doorkeeper-gem/doorkeeper/wiki/Authorization-Code-Flow

下記をブラウザでアクセスすると、ログイン、同意画面があらわれます。すべてうまくいけば認可コード(Authorization Code）が発行されます
http://localhost:2000/oauth/authorize?response_type=code&client_id=test_uid&client_secret=test_secret&redirect_uri=urn:ietf:wg:oauth:2.0:oob

ログインユーザーは
email: user1@example.com 
password: Password1 
を使ってください

### 2. アクセストークンの取得（図の10,11）
発行された認可コードを用いて、アクセストークンの取得を行います。

認可コードの使用期限が短いので、認可コード取得から時間が経ってしまった場合は認可コード習得から行ってください。

```ruby
curl \
-F client_id=test_uid \
-F client_secret=test_secret \
-F redirect_uri=urn:ietf:wg:oauth:2.0:oob \
-F code=#{得られた認可コード} \
-F grant_type=authorization_code \
-X POST http://localhost:2000/oauth/token \
| jq
```

response

アクセストークンが得られます。id_token は ユーザーの認証を証明するためのトークンで、クライアント側でチェックが行われます。（サーバー側は返すだけで基本使わない）

Ref. https://qiita.com/asagohan2301/items/cef8bcb969fef9064a5c

```ruby
{
  "access_token": "kiYNazG5XWBcLvvXtgyPrmiIeXJ6tq1RReo7UGFx10M",
  "token_type": "Bearer",
  "expires_in": 7200,
  "scope": "read openid",
  "created_at": 1740762275,
  "id_token": "eyJ0eXAiOiJKV1QiLCJraWQiOiJCWjVyS3g1THZTQlRncm93YUNNdWZwNXlSSjZSNHd2OTh6WGNqMU1scEk4IiwiYWxnIjoiUlMyNTYifQ.eyJpc3MiOiJpc3N1ZXIgc3RyaW5nIiwic3ViIjoiYzVkYWJlOTNiYTI4YmU0ZGM3YWUyYWI4NTFhMzQ2MzUzNjgyZTE3ODc3OGVlYTViOTZhYzdhZjJjZTEwYmZmZiIsImF1ZCI6InRlc3RfdWlkIiwiZXhwIjoxNzQwNzYyMzk1LCJpYXQiOjE3NDA3NjIyNzV9.lyRSNq2tM3hzahcv0-KO00eDoLFLWBfJRaBCrN_mPrurN_94Lh1Yk6Kf-5Nq7JAf365Zd3Mpkx0amQAsVoyifvB1EFZl0yopH4jiasTASjl_IpBXB3YRsDQubgM2MTSYRRxsttV3F6RCWUcDmy2kshkHIdOjjBfdwtuv_Fx7ee5BTAjN5saT3Xvxkza0Pmz1RON09XaqeBPrhX1Rm5zpBXQlb2KcfbZboZqsmC5P14lfn5iz2cM1w76Teb5pffHLOvitSwpheghblvc14shHfQx-fgRd56MoNCE915YzOk0j-5h2SgTXPBhZ_qI827jLRrl2XNGutzh046H6qCGrGA"
}
```


### 3. リソースサーバーへのアクセス（図の12,13）
アクセストークンを用いてリソースサーバーの情報を取得します

アクセストークンはユーザーと紐づいているので、アクセストークンからユーザーが特定でき、適切な情報を返します

```ruby
curl -H GET 'http://localhost:2000/api/v1/me' \
-H 'Content-Type:application/json;charset=utf-8' \
-H 'Authorization: Bearer #{得られたアクセストークン}' \
| jq
```

response
```ruby
{
  "id": 1,
  "email": "user1@example.com",
  "created_at": "2025-02-27T05:37:38.177Z",
  "updated_at": "2025-02-27T05:37:38.177Z"
}
```

