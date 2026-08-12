# GMornVersion

## 概要

ビルドの版（タグ付きビルドしたときのタグ）を、任意のシーンへ気軽に出すGodotアドオン。

版を `.tscn` へ直に書くと、書き出しても変わらないまま古い版が出続ける。どの版を触っているのか分からないと、報告をもらっても突き合わせられない。出どころを1つに決め、書き出しの手順がそこへタグを書き込む形にする。

## 動作環境

- Godot 4.x（4.7で確認）
- 版を書き込む書き出しの手順（GitHub Actions など）。無くても動く（そのときは `dev` と出る）

## 何ができるか

- **置くだけで出る**。版を出したい Label に `gmorn_version_label.gd` を付けるだけ。エディタ上でも出るので、置いた場所と大きさをその場で確かめられる。
- **出どころが1つ**。`application/config/version` だけを見る。Godotが元から持っている項目なので、新しい置き場を増やさない。
- **未設定でも空にならない**。設定が無ければ `dev` と出る。空文字だと、出す側が「まだ読めていない」のか「版が無い」のか区別できない。
- **前置き・後置きを足せる**。`ver_1.2.3` や `1.2.3 (試作)` のように出せる。
- **部品が無くても動く**。自動読み込みが居なければ、Label が同じ出どころから自分で読む。

## 使い方

### 1. 取り込む

アドオン一式をリポジトリ直下へ置いてある。取り込む側の `addons/gmorn_version` へそのまま submodule として足せる。

```
git submodule add https://github.com/TsukumiStudio/GMornVersion.git addons/gmorn_version
```

Godotのエディタで「プロジェクト設定 → プラグイン」から `GMornVersion` を有効にする。自動読み込みへ `GMornVersion` が登録される。

**リポジトリ直下に `project.godot` は置かない。** 置くとGodotがそこを別のプロジェクトと見なし、**そのフォルダを丸ごとスキャンから外す**。submoduleとして取り込んだ場合、エディタでは動くのに書き出した実行ファイルにだけアドオンが入らない。

### 2. 画面へ出す

版を出したい場所に Label を置き、`gmorn_version_label.gd` を付ける。それだけでよい。

`.tscn` へ書くならこうなる。

```
[node name="Version" type="Label" parent="."]
script = ExtResource("gmorn_version_label")
```

自分で組み立てたいときは読むだけでもよい。

```gdscript
var version := get_node_or_null("/root/GMornVersion")
if version != null:
    my_label.text = version.text()
```

### 3. 書き出しの手順でタグを書き込む

これをしないと、配ったものの版が変わらない。GitHub Actions なら、書き出しの前に1段はさむ。

```yaml
      - name: Stamp the tag into the project version
        shell: bash
        run: |
          set -euo pipefail
          python3 - "$GITHUB_REF_NAME" <<'PY'
          import re, sys
          tag = sys.argv[1]
          path = "project.godot"
          text = open(path, encoding="utf-8").read()
          if re.search(r'^config/version=.*$', text, re.M):
              text = re.sub(r'^config/version=.*$', 'config/version="%s"' % tag, text, count=1, flags=re.M)
          else:
              text = text.replace('config/name=', 'config/version="%s"\nconfig/name=' % tag, 1)
          open(path, "w", encoding="utf-8").write(text)
          PY
```

`project.godot` に置き場を用意しておく。

```
[application]

config/version="dev"
```

手元で動かしているときは `dev` のまま出る。配ったものにはタグが出る。

### 4. 出し方を変える

| 項目 | プロジェクト設定 | 環境変数 | 既定 |
| --- | --- | --- | --- |
| 読む場所 | `gmorn_version/setting_path` | — | `application/config/version` |
| 前置き | `gmorn_version/prefix` | `GMORN_VERSION_PREFIX` | 空 |
| 後置き | `gmorn_version/suffix` | — | 空 |
| 未設定のときの文字 | `gmorn_version/fallback` | `GMORN_VERSION_FALLBACK` | `dev` |

### その他の口

| 呼び出し | 何をするか |
| --- | --- |
| `text()` | 前置き・後置きを付けた、画面へ出す文字 |
| `version()` | 版そのもの。未設定なら `fallback` |
| `is_stamped()` | 版が設定されているか。未設定なら `false` |
| `refresh()`（Label 側） | 読み直して表示へ映す |

### 手を入れる

`verify.sh` で、版の読み取りと表示への反映が通ることを確かめられる。一時の置き場へ最小のプロジェクトを作り、この部品を写して回す。

```
./verify.sh
```

## ライセンス

Unlicense（パブリックドメイン）。
