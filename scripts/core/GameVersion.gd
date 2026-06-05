extends Node

const VERSION := "0.1.0-beta.1"
const BUILD_NAME := "Closed Beta Cleanup"
const BUILD_DATE := "2026-06-05"

func get_version_label() -> String:
	return "v%s — %s (%s)" % [VERSION, BUILD_NAME, BUILD_DATE]
