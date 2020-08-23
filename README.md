# asciidoctor-nabetani

An assortment of things I needed to make a Japanese PDF document with asciidoctor.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'asciidoctor-nabetani'
```

And then execute:

```
$ bundle install
```

Or install it yourself as:

```
$ gem install asciidoctor-nabetani
```


## Usage

TODO: Write usage instructions here

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/nabetani/asciidoctor-nabetani.

## Special Thanks

This project is inspired by [asciidoctor-pdf-linewrap-ja](https://github.com/fuka/asciidoctor-pdf-linewrap-ja)

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Asciidoctor::Nabetani project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/asciidoctor-nabetani/blob/master/CODE_OF_CONDUCT.md).

## What is this

突然日本語ですいません。

AsciiDoctor で PDF を作るときに困っていたことをなんとかしたライブラリ。

### 禁則処理の改善

`asciidoctor/nabetani/prawn-linewrap-ja` を require すると有効になる。

prawn の禁則処理を本ライブラリの処理で差し替えることで、禁則処理を改善する。

### クロスリファレンス

`asciidoctor/nabetani/abstractblock-xreftext` を require すると有効になる。

AsciiDoc のクロスリファレンスで

従来は
|形式名|PDF上の出力例|
|:--|:--|
|full|`Section 2.1, “セクション名”`|
|short|`Section 2.1`|
|basic|`セクション名`|
の三択だった。

これを

```
:xrefstyle:  custom
:xrefcustomformat: [$SECT_NUMS$]. [$TITLE$]
```
などと指定することで、PDF上で
```
2.1. セクション名
```
とすることができるようにする。

|記号|意味|
|:--|:--|
|[$SECT_NUMS$]|セクション番号をピリオドでつないだもの。`2.1` など|
|[$TITLE$]|セクション名|

※ 上記以外はそのまま出力される。

### horizontal な定義リスト

`asciidoctor/nabetani/horz-dlist` を require すると有効になる。

horizontal な定義リストで
```
[horizontal, margin-left=20, margin-bottom=10]
Foo:: bar
Baz Qux:: quux corge
```
のように指定することで、左マージンと下マージンを指定することができる。
指定する数字の単位は PDF point だと思う。

### PDF のプロパティ

`asciidoctor/nabetani/pdf-custom-property` を require すると有効になる。

PDF のファイル情報の「概要」欄の項目を adoc ファイル内に

```
// タイトルを「PDF Title」にする
:pdf_title: PDF Title
```

のように書くことで、個別に指定できる。

指定可能な項目は下表の通り:
|アトリビュート名|Acrobat Reader の「概要」欄の日本語名|例|
|:--|:--|:--|
|pdf_title|タイトル|Starfish Wars|
|pdf_author|作成者|鍋谷武典|
|pdf_subject|サブタイトル|ビピンナリアの復讐|
|pdf_keywords|キーワード|ヒトデ 棘皮動物 Starfish|
|pdf_producer|PDF変換|Acrobat Distiller|
|pdf_creator|アプリケーション|FrameMaker 6.0|

### PDF のしおり(outline)

`asciidoctor/nabetani/pdf-outline` を require することで有効になる。

通常の asciidoctor-pdf でビルドした場合、PDF のしおり欄の先頭は 表紙になるが、この機能を有効にすると、表紙はしおりにふくまれないようになる。







