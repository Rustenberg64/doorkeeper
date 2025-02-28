### 動作確認

![image](https://github.com/user-attachments/assets/532f481f-ffa6-4d32-be3e-3e2f5a78d796)


https://authya.booth.pm/items/1550861より引用

前準備 クライアントの登録

3 - 9 認可コードの発行

10,11 アクセストークンの取得

13, 14 UserInfoエンドポイントへのアクセス

その他 リソースサーバーへのアクセス

前準備 クライアントの登録

```ruby
Doorkeeper::Application.create!(
name: 'test_app',
uid: 'test_uid',
secret: 'test_secret',
redirect_uri: 'urn:ietf:wg:oauth:2.0:oob', # 本来はクライアントアプリのuriを設定するが、テスト用にこの値を設定する
scopes: 'read openid', # openidを使いたい場合はスコープに追加が必要
confidential: true,
)
```

3 - 9 認可コードの発行

https://github.com/doorkeeper-gem/doorkeeper/wiki/Authorization-Code-Flow

ブラウザでアクセス

http://localhost:2000/oauth/authorize?response_type=code&client_id=test_uid&client_secret=test_secret&redirect_uri=urn:ietf:wg:oauth:2.0:oob

responseとして認可コードが返ってくる

10,11 アクセストークンの取得

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

13, 14 UserInfoエンドポイントへのアクセス

```ruby
curl -H GET 'http://localhost:2000/oauth/userinfo' \
-H 'Content-Type:application/json;charset=utf-8' \
-H 'Authorization: Bearer #{得られたアクセストークン}' \
| jq
```

response （本来はユーザーのidやemail、profileを返す）

```ruby
{
  "sub": "c5dabe93ba28be4dc7ae2ab851a346353682e178778eea5b96ac7af2ce10bfff"
}
```

その他 リソースサーバーへのアクセス

```ruby
curl -H GET 'http://localhost:2000/api/v1/me' \
-H 'Content-Type:application/json;charset=utf-8' \
-H 'Authorization: Bearer #{得られたアクセストークン}' \
| jq

```

response
