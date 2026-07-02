extends Node

const VERSION := "0.1.0-beta.6"
const BUILD_NAME := "Spinning Gear & Tackle Cleanup"
const BUILD_DATE := "2026-07-02"

func get_version_label() -> String:
	return "v%s — %s (%s)" % [VERSION, BUILD_NAME, BUILD_DATE]
