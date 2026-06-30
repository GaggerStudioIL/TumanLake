extends RefCounted

const DEFAULT_AVATAR_ID := "ava1"

const AVATARS := [
	{
		"id": "ava1",
		"title": "Avatar 1",
		"small_path": "res://assets/ui/avatars/small/ava1.png",
		"big_path": "res://assets/ui/avatars/big/ava1_big.png"
	},
	{
		"id": "ava2",
		"title": "Avatar 2",
		"small_path": "res://assets/ui/avatars/small/ava2.png",
		"big_path": "res://assets/ui/avatars/big/ava2_big.png"
	},
	{
		"id": "ava3",
		"title": "Avatar 3",
		"small_path": "res://assets/ui/avatars/small/ava3.png",
		"big_path": "res://assets/ui/avatars/big/ava3_big.png"
	},
	{
		"id": "ava4",
		"title": "Avatar 4",
		"small_path": "res://assets/ui/avatars/small/ava4.png",
		"big_path": "res://assets/ui/avatars/big/ava4_big.png"
	},
	{
		"id": "ava5",
		"title": "Avatar 5",
		"small_path": "res://assets/ui/avatars/small/ava5.png",
		"big_path": "res://assets/ui/avatars/big/ava5_big.png"
	},
	{
		"id": "ava6",
		"title": "Avatar 6",
		"small_path": "res://assets/ui/avatars/small/ava6.png",
		"big_path": "res://assets/ui/avatars/big/ava6_big.png"
	},
	{
		"id": "ava7",
		"title": "Avatar 7",
		"small_path": "res://assets/ui/avatars/small/ava7.png",
		"big_path": "res://assets/ui/avatars/big/ava7_big.png"
	},
	{
		"id": "ava8",
		"title": "Avatar 8",
		"small_path": "res://assets/ui/avatars/small/ava8.png",
		"big_path": "res://assets/ui/avatars/big/ava8_big.png"
	},
	{
		"id": "ava9",
		"title": "Avatar 9",
		"small_path": "res://assets/ui/avatars/small/ava9.png",
		"big_path": "res://assets/ui/avatars/big/ava9_big.png"
	},
	{
		"id": "ava10",
		"title": "Avatar 10",
		"small_path": "res://assets/ui/avatars/small/ava10.png",
		"big_path": "res://assets/ui/avatars/big/ava10_big.png"
	},
	{
		"id": "ava11",
		"title": "Avatar 11",
		"small_path": "res://assets/ui/avatars/small/ava11.png",
		"big_path": "res://assets/ui/avatars/big/ava11_big.png"
	},
	{
		"id": "ava12",
		"title": "Avatar 12",
		"small_path": "res://assets/ui/avatars/small/ava12.png",
		"big_path": "res://assets/ui/avatars/big/ava12_big.png"
	}
]


static func get_avatars() -> Array:
	return AVATARS.duplicate(true)


static func normalize_avatar_id(avatar_id: String) -> String:
	var normalized_id := avatar_id.strip_edges()
	for avatar in AVATARS:
		if str(avatar.get("id", "")) == normalized_id:
			return normalized_id
	return DEFAULT_AVATAR_ID


static func get_avatar(avatar_id: String) -> Dictionary:
	var normalized_id := normalize_avatar_id(avatar_id)
	for avatar in AVATARS:
		if str(avatar.get("id", "")) == normalized_id:
			return avatar
	return AVATARS[0]


static func get_small_texture(avatar_id: String) -> Texture2D:
	return _load_texture(str(get_avatar(avatar_id).get("small_path", "")))


static func get_big_texture(avatar_id: String) -> Texture2D:
	return _load_texture(str(get_avatar(avatar_id).get("big_path", "")))


static func get_title(avatar_id: String) -> String:
	return str(get_avatar(avatar_id).get("title", "Avatar"))


static func _load_texture(path: String) -> Texture2D:
	if path.is_empty():
		return null
	return load(path) as Texture2D
