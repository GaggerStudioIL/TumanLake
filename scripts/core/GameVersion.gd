extends Node

const VERSION := "0.1.0-beta.3"
const BUILD_NAME := "HUD and Cast Control Refresh"
const BUILD_DATE := "2026-06-23"

func get_version_label() -> String:
	return "v%s — %s (%s)" % [VERSION, BUILD_NAME, BUILD_DATE]
