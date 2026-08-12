extends Node

## ビルドの版を1か所から配る。
##
## 版の出どころは `application/config/version` の1つだけにする。書き出しの手順
## （CI）がタグの名前をそこへ書き込めば、配ったものにはタグがそのまま出る。
## 画面へ直に書くと書き出しても変わらず、どの版を触っているのか分からなくなる。
##
## 使い方は README.md を参照。おおよそ次のどちらかで足りる。
##
##   Label へ `gmorn_version_label.gd` を付ける        置くだけで出る
##   GMornVersion.text() を読む                        自分で組み立てる

const SETTINGS := preload("gmorn_version_settings.gd")

var _settings: RefCounted

## 設定。**`_ready` を待たずに読めるようにする。**
##
## 自動読み込みの `_ready` より先に `text()` が呼ばれることがある
## （シーンを `_init` の中で組み立てるツールなど）。`_ready` で作る形だと
## そこで「Nil に prefix は無い」と落ち、「版が出ない」ではなく
## 「エラーで止まる」になって原因を追いにくい。
func settings() -> RefCounted:
	if _settings == null:
		_settings = SETTINGS.new()
		_settings.load_from_environment()
	return _settings

## 画面へ出す文字。前置きと後置きを付けた形で返す。
##
## 版が空のときは `fallback`（既定は `dev`）を使う。空文字を返すと、出す側が
## 「まだ読めていない」のか「版が無い」のか区別できない。
func text() -> String:
	var config := settings()
	return "%s%s%s" % [config.prefix, version(), config.suffix]

## 版そのもの。`v1.2.3` のようなタグの名前が入る。
func version() -> String:
	var config := settings()
	var value := String(ProjectSettings.get_setting(config.setting_path, ""))
	return value if not value.is_empty() else config.fallback

## 版が設定されているか。設定されていなければ `fallback` を返している。
func is_stamped() -> bool:
	return not String(ProjectSettings.get_setting(settings().setting_path, "")).is_empty()
