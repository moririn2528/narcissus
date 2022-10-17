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
- latitude
- longitude
- length
(latitude,longitude)を中心としたlengthメートル四方にある投稿情報を距離が近い順に返す
lengthを指定しない場合はデフォルト値(今は1000メートル四方)になる

### 戻り値
以下の値の組のリストがJSONの文字列として返る
- id (植物のID)
- name (植物の名前)
- url (植物の画像のURL)
- latitude (投稿時の緯度)
- longitude (投稿時の経度)
- distance (その場所までの距離)
