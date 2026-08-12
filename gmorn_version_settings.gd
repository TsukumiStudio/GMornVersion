extends RefCounted

## GMornVersion の設定。
##
## `class_name` は付けない。付けるとエディタが一度走査するまで名前を引けず、
## 取り込んだ直後にヘッドレスで走らせると読み込みごと失敗する。使う側は
## `preload` で直に指す。

## 版を読む場所。既定はGodotが元から持っている項目。
var setting_path := "application/config/version"
## 版の前に付ける文字。`ver_` のように出したいときに使う。
var prefix := ""
## 版の後ろに付ける文字。
var suffix := ""
## 版が設定されていないときに出す文字。空にはしない。空だと、出す側が
## 「まだ読めていない」のか「版が無い」のか区別できない。
var fallback := "dev"

const SETTING_PREFIX := "gmorn_version/"

## 設定を読み込む。自分自身へ書き込むので、作ってから呼ぶ。
func load_from_environment() -> void:
	setting_path = String(_setting("setting_path", setting_path))
	prefix = String(_setting("prefix", prefix))
	suffix = String(_setting("suffix", suffix))
	fallback = String(_setting("fallback", fallback))
	# 環境変数は最後に効かせる。手元だけ出し方を変えたいときに使う。
	prefix = _environment("GMORN_VERSION_PREFIX", prefix)
	fallback = _environment("GMORN_VERSION_FALLBACK", fallback)

static func _setting(key: String, fallback_value: Variant) -> Variant:
	var path := SETTING_PREFIX + key
	if not ProjectSettings.has_setting(path):
		return fallback_value
	return ProjectSettings.get_setting(path, fallback_value)

static func _environment(key: String, fallback_value: String) -> String:
	var value := OS.get_environment(key)
	return value if not value.is_empty() else fallback_value
