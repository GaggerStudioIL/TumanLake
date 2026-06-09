extends Node

const VERSION := "0.1.0-beta.2"
const BUILD_NAME := "Tackle Stability Fixes"
const BUILD_DATE := "2026-06-09"

func get_version_label() -> String:
	return "v%s — %s (%s)" % [VERSION, BUILD_NAME, BUILD_DATE]
