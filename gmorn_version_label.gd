extends Label

## 置くだけで版が出る Label。
##
## 版を出したい場所へこのスクリプトを付ける。それだけでよい。`.tscn` に版を
## 直に書くと、書き出しても変わらないまま古い版が出続ける。
##
## エディタ上でも出るので、置いた場所と大きさをその場で確かめられる。

const VERSION_PATH := "res://addons/gmorn_version/gmorn_version.gd"

## 自動読み込みが無い環境（部品を取り込んでいない、単体で開いている）でも
## 出せるように、自前でも組み立てられるようにしてある。
@export var refresh_on_ready := true

func _ready() -> void:
	if refresh_on_ready:
		refresh()

## 版を読み直して表示へ映す。
func refresh() -> void:
	var service := get_node_or_null("/root/GMornVersion")
	if service != null:
		text = service.text()
		return
	# 部品が居ないときは、同じ出どころから自分で読む。
	var settings_script: GDScript = load("res://addons/gmorn_version/gmorn_version_settings.gd")
	if settings_script == null:
		text = String(ProjectSettings.get_setting("application/config/version", "dev"))
		return
	var settings: RefCounted = settings_script.new()
	settings.load_from_environment()
	var value := String(ProjectSettings.get_setting(settings.setting_path, ""))
	if value.is_empty():
		value = settings.fallback
	text = "%s%s%s" % [settings.prefix, value, settings.suffix]
