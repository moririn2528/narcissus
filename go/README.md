# API

## /plant
### 戻り値
以下の値の組のリストがJSONの文字列として返る
- id (植物のID, int)
- name (植物の名前, string)
- url (植物の画像のURL, string)
- detail (植物の説明, string)

## /near
### パラメータ
(latitude,longitude)を中心としたlengthメートル四方にある投稿情報を距離が近い順に返す。  
lengthを指定しない場合はデフォルト値(今は1000メートル四方)になる。
- latitude (float64)
- longitude (float64)
- length (float64)

### 戻り値
結果が空かどうかのIsEmptyと結果のリストが返る  
IsEmptyは、結果のリストが空なら1、そうでないなら0  

結果のリスト:以下の値の組のリストがJSONの文字列として返る
- id (植物のID, int)
- name (植物の名前, string)
- url (植物の画像のURL, string)
- detail (植物の説明, string)
- latitude (投稿時の緯度, float64)
- longitude (投稿時の経度, float64)
- distance (その場所までの距離, float64)
- timestamp (投稿日時, string)

## /post/upload
POST送信でJSONを送ると投稿内容をデータベース(upload_postテーブル)に保存できる。  
その植物のデータがなければ新たに登録する。  
その際に複数のtagをリクエストとして送信すると、植物とタグの関連のデータを追加する。タグが存在しなければタグを追加する。  

### POST送信のJSON
tagsは無くても良いけど一応残しとく
- plant_id 植物のID
- latitude 緯度 float64
- longitude 経度 float64
- hash 画像のhash string
- tags タグ名(string)のリスト 植物のタグ(植物にタグを登録できる)

### 戻り値
なし

## /search
POST送信でJSON(必須タグのリストと任意タグのリスト)を送ると、必須タグをすべて含んだ植物情報が返ってくる。任意タグを含むものから並ぶ。

### POST送信のJSON
- necessary_tags 必須タグid(int)のリスト　空(null)でもよい
- optional_tags 任意タグid(int)のリスト　空(null)でもよい

### 戻り値
以下の値の組のリストがJSONの文字列として返る
- id (植物のID, int)
- name (植物の名前, string)
- url (植物の画像のURL, string)
- detail (植物の説明, string)