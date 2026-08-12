extends SceneTree

## 版の読み取りと表示への反映を確かめる。

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var service_script: GDScript = load("res://addons/gmorn_version/gmorn_version.gd")
	# **木に入れる前に読めること。** 自動読み込みの `_ready` より先に
	# `text()` が呼ばれる取り込み方がある（シーンを `_init` の中で組み立てる
	# ツールなど）。`_ready` で設定を作る形だと、そこで
	# 「Nil に prefix は無い」と落ちていた。
	ProjectSettings.set_setting("application/config/version", "v0.0.1")
	var early: Node = service_script.new()
	assert(early.text() == "v0.0.1",
		"_ready の前に読めない（出た文字は %s）" % early.text())
	early.free()

	var service: Node = service_script.new()
	root.add_child(service)
	await process_frame

	# 設定された版がそのまま出る。
	ProjectSettings.set_setting("application/config/version", "v1.2.3")
	assert(service.version() == "v1.2.3", "版が %s" % service.version())
	assert(service.is_stamped(), "設定してあるのに未設定と見なされる")
	assert(service.text() == "v1.2.3", "出す文字が %s" % service.text())

	# 前置きと後置きが付く。
	service.settings().prefix = "ver_"
	service.settings().suffix = " (試作)"
	assert(service.text() == "ver_v1.2.3 (試作)", "前置き後置きが効かない: %s" % service.text())
	service.settings().prefix = ""
	service.settings().suffix = ""

	# 未設定なら控えの文字を出す。空文字は返さない。空だと、出す側が
	# 「まだ読めていない」のか「版が無い」のか区別できない。
	ProjectSettings.set_setting("application/config/version", "")
	assert(not service.is_stamped(), "空なのに設定済みと見なされる")
	assert(service.version() == service.settings().fallback,
		"未設定のとき %s が出た" % service.version())
	assert(not service.text().is_empty(), "未設定のとき空文字が出た")

	# Label へ付けるだけで出る。
	ProjectSettings.set_setting("application/config/version", "v9.9.9")
	var label_script: GDScript = load("res://addons/gmorn_version/gmorn_version_label.gd")
	var label: Label = label_script.new()
	root.add_child(label)
	await process_frame
	assert(label.text == "v9.9.9", "Labelへ出た文字が %s" % label.text)

	# 版が変わったら読み直せる。
	ProjectSettings.set_setting("application/config/version", "v9.9.10")
	label.refresh()
	assert(label.text == "v9.9.10", "読み直しても %s のまま" % label.text)

	print("版=%s 出す文字=%s" % [service.version(), service.text()])
	print("GMORN VERSION VERIFY: PASS")
	quit(0)
