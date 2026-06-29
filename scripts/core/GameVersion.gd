extends Node

const VERSION := "0.1.0-beta.4"
const BUILD_NAME := "Cast Freeze & Spinning Hotfix"
const BUILD_DATE := "2026-06-30"

func get_version_label() -> String:
	return "v%s — %s (%s)" % [VERSION, BUILD_NAME, BUILD_DATE]
