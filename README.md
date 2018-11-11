# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...

## コンセプト
コード進行と楽曲のセットを保存できるサービス。

## 使い方
- 任意の楽曲を指定する。
  - YouTubeURLをペースト
  - YouTubeを直接検索
- 任意のコード進行を入力する。
  - 補完・サジェストがあると理想。
- 自身のリストに登録する。

## コード進行の仕様
- コード進行というテーマ上、ユーザーが極めてマニアックなので、マニアックな仕様で進める。
  - 万人にわかりやすいシステムではなく、コード進行が好きな人が満足する仕様に。
- 具体的には？
  - 数字でコード進行が理解できる人にとっては、進行は数字で表現した方が良い。というか、個人的にその方が良い。
    - 1564
  - その手前の、数字ではわからないユーザーを取り込むべきか？
    - 取り込めると理想だが…
  - 解決策
    - 具体的なコード + 数字コードの両方での登録を可能にする
    - 数字でわからない人はコード
    - 数字がわかる人は数字で入力すれば良い。
    - → 特定のコードで探すか、特定の数字で探すかの違い

## コードの構造
- 基音 : 主にベース音
  - C, G, A
  - 1, 2, 3, 4, 5
- メジャー/マイナー
  - M, m
- 4和音以上
  - m7, aug6, sus4, add9

書いてみてわかったことだが、基音の部分が数字か具体的なコードかを書き換えるだけで良さそう。

- base_note_str : {C,C#/D♭,D,D#/E♭,E,F,F#/G♭,G,G#/A♭,A,A#/B♭,B}
- base_note_num : {1,2,3,4,5,6,7}
- triad : {M,m}
- fourth : {sus4,aug6,M7,m7,add9,m-5,dim,}
- on_chord_str : {C,C#/D♭,D,D#/E♭,E,F,F#/G♭,G,G#/A♭,A,A#/B♭,B}
- on_chord_num : {1,2,3,4,5,6,7}

## 楽曲の登録
