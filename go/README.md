# API

## /plant
### 戻り値
{
    plant:[
        {
            id: 0,
            name: "hoge",
            url: "huga"
        },
        {
            id: 1,
            name: "piyo",
            url: "url"
        },
    ]
    status: 200
}

## /near
### パラメータ
(latitude,longitude)を中心としたlengthメートル四方にある投稿情報を距離が近い順に返す。  
lengthを指定しない場合はデフォルト値(今は1000メートル四方)になる。
- latitude (float64)
- longitude (float64)
- length (float64)

### 戻り値
以下の値の組のリストがJSONの文字列として返る。
- id (植物のID, int)
- name (植物の名前, string)
- url (植物の画像のURL, string)
- latitude (投稿時の緯度, float64)
- longitude (投稿時の経度, float64)
- distance (その場所までの距離, float64)

## /post
今はGETで受け取っているが、画像を受け取るために後でPOSTに変える。  
パラメータを指定して送信すると投稿内容をデータベース(postテーブル)に保存できる。  
その植物のデータがなければ新たに登録する。  
その際に複数のtagをリクエストとして送信すると、植物とタグの関連のデータを追加する。タグが存在しなければタグを追加する(これ別のAPIに分けたほうが良い？)。

### パラメータ
- name 植物の名前
- hash 画像のURL　これは後で画像のバイナリ(base64)に変える
- latitude 緯度 float64
- longitude 経度 float64
- tag1, tag2, ... 植物のタグ(空でも良い　初の植物を登録するときに便利？)

### 戻り値
- isnew 1なら植物データを新しく登録 0なら既に存在
- newid 新しく登録した際のid(これ要る？)