---
title: リモートリポジトリの Personal Access Token のローカルでの管理
category: tech
tags: [git]
---

## 問題

普段は public repository にソースコードを保管しているが、誰でもみれることが好ましくない場合に遭遇し、private repository を作る。

しかし、Private repository へ `git clone` などのクライアントからの操作を行う場合は、Personal Access Token を発行し、パスワードに設定する必要があった。repository ごとにPersonal Access Token を発行するのは面倒なので解決した。

## 解決方法

以下を実行するだけ。

```sh
git config --global url.https://<username>:<personal access token>@github.com/.insteadOf https://github.com/
```

## 追記

git credential-helper を利用する方法を知った。

<https://git-scm.com/book/ja/v2/Git-%E3%81%AE%E3%81%95%E3%81%BE%E3%81%96%E3%81%BE%E3%81%AA%E3%83%84%E3%83%BC%E3%83%AB-%E8%AA%8D%E8%A8%BC%E6%83%85%E5%A0%B1%E3%81%AE%E4%BF%9D%E5%AD%98>

以下のコマンドで設定できる。

```bash
git config --global credential.helper store
```

- **store**: 認証情報を平文で保存する。デフォルトで ~/.git-credentials に保存される。
- **cache**: 認証情報を一時的にメモリに保存する。デフォルトで15分間保存される。

`git clone` するときに password として Personal Access Token を入力すると、次回以降は ~/.git-credentials から自動的に読み込まれる。`--global` オプションを付けることで、そのホストのそのユーザが扱うすべてのリポジトリで共通して利用できる。また、色々なオリジンに対しても自動的にトークンを切り替えてくれる。

ただし、平文で保存されるので、セキュリティには気を付けた方が良い。デフォルトの credential helper 以外にも、OS のキーチェーンを利用する方法などがあるので、そちらも検討すると良い。
