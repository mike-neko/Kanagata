# Kanagata

[![GitHubのライセンス](https://img.shields.io/badge/license-MIT-blue.svg)](https://raw.githubusercontent.com/mike-neko/Kanagata/master/LICENSE)
[![Build Status](https://travis-ci.org/mike-neko/Kanagata.svg?branch=master)](https://travis-ci.org/mike-neko/Kanagata)
[![codecov](https://codecov.io/gh/mike-neko/Kanagata/branch/master/graph/badge.svg)](https://codecov.io/gh/mike-neko/Kanagata)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/mike-neko/Kanagata)
[![CocoaPods](https://img.shields.io/cocoapods/v/Kanagata.svg)](http://cocoadocs.org/docsets/Kanagata)
[![CocoaPods](https://img.shields.io/cocoapods/p/Kanagata.svg)](http://cocoadocs.org/docsets/Kanagata)


`Kanagata`はJSONのデコードとエンコードを行えるSwiftで書かれたライブラリです。

Swiftの安全性とJSONの柔軟性をほどよく組み合わせつつ、直感的に書くことができます。

## 特徴
- フォーマットベース
  - JSONのキー名と値の型をデータとして定義できる  
（クラスを定義したりコードを書く必要がない。また実行時の動的な変更が可能）
  - 変換時に指定したフォーマットかバリデーションされる  
- 書きやすく、読みやすい 
- タイプセーフ

## インストール
### Carthage
1\. プロジェクトの`Cartfile`に以下を追記してください。
```
github "mike-neko/Kanagata"
```

2\. フレームワークを`import`してください。
```
import Kanagata
```

### CocoaPods
1\. プロジェクトの`Podfile`に以下を追記してください。
```
pod 'Kanagata'
```

2\. フレームワークを`import`してください。
```
import Kanagata
```

### 手動
フレームワークを使わずに利用ができます。   
その場合は`Kanagata/JSON.swift`をプロジェクトに追加するだけです。

## 使い方

### フォーマットの定義
最初に変換したいJSONのフォーマットを定義します。

例えば、`{ "name": "Mike", "age": 20 }`というJSONは以下の様に定義できます。

```
let format: JSON.Format = [
    "name": .string,        // キー名: name, 中身はString
    "age": .int             // キー名: age, 中身はInt
]
```
### JSONから変換する

文字列からの場合
```
let json = try JSON(string: text, format: format)
```

`Data`からの場合
```
let json = try JSON(data: data, format: format)
```

もし、指定したフォーマットと一致しない場合は例外が発生します。

### 値を取得する
値の取得には各型毎に3つのパターンがあります。

```
name = String(json: json["name"])
name = try json["name"].stringValue()
let name: String = json["name"].value()
```

オブジェクトや配列から取り出す場合
```
// { errors: [1, 3, 4 ] }
json["errors"][0]               // 1
// { error: { code: 100 } }
json["error"]["code"]           // 100
```

### 値を設定する

値を設定（変更）することもできます。
ただし、フォーマットと一致する型のみ設定できます。

```
json["age"] = JSONData.value(21)        // 21に更新
```

### JSONへ変換する

```
// Stringへ変換する場合
let jsonString = try json.stringData()
// Dataへ変換する場合
let jsonData = try json.data()
```

もし、指定したフォーマットと一致しない場合は例外が発生します。

# その他の情報
- [Wiki](https://github.com/mike-neko/Kanagata/wiki)
- [CocoaDocs](http://cocoadocs.org/docsets/Kanagata/)
