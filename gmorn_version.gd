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

var settings: RefCounted

func _ready() -> void:
	settings = SETTINGS.new()
	settings.load_from_environment()

## 画面へ出す文字。前置きと後置きを付けた形で返す。
##
## 版が空のときは `fallback`（既定は `dev`）を使う。空文字を返すと、出す側が
## 「まだ読めていない」のか「版が無い」のか区別できない。
func text() -> String:
	return "%s%s%s" % [settings.prefix, version(), settings.suffix]

## 版そのもの。`v1.2.3` のようなタグの名前が入る。
func version() -> String:
	var value := String(ProjectSettings.get_setting(settings.setting_path, ""))
	return value if not value.is_empty() else settings.fallback

## 版が設定されているか。設定されていなければ `fallback` を返している。
func is_stamped() -> bool:
	return not String(ProjectSettings.get_setting(settings.setting_path, "")).is_empty()
