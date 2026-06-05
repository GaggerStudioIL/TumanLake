extends Node

enum FishStatus {
	UNDERSIZED,
	KEEPER,
	TROPHY,
	RARE_RECORD
}

enum FishRarity {
	COMMON,
	RARE,
	LEGENDARY_SPECIES
}

enum BuyerType {
	LOCAL_MARKET,
	FISH_SHOP,
	RESTAURANT,
	WHOLESALE_BUYER,
	COLLECTOR,
	EXPORT_COMPANY
}

enum ItemCondition {
	NEW,
	USED,
	WORN,
	BROKEN
}

enum TackleSlot {
	ROD,
	LINE,
	LEADER,
	FLOAT,
	HOOK,
	BAIT,
	BAIT_2,
	REEL,
	LURE,
	FEEDER_RIG,
	HOOK_OR_LURE,
	SINKER_OR_RIG
}

enum TackleType {
	FLOAT,
	SPINNING,
	FEEDER,
	SEA
}

enum MarketTrend {
	DOWN,
	STABLE,
	UP
}

const FISH_STATUS_KEYS := {
	FishStatus.UNDERSIZED: "undersized",
	FishStatus.KEEPER: "keeper",
	FishStatus.TROPHY: "trophy",
	FishStatus.RARE_RECORD: "rare_record"
}

const FISH_RARITY_KEYS := {
	FishRarity.COMMON: "common",
	FishRarity.RARE: "rare",
	FishRarity.LEGENDARY_SPECIES: "legendary_species"
}


func fish_status_key(value: int) -> String:
	return str(FISH_STATUS_KEYS.get(value, "undersized"))


func fish_rarity_key(value: int) -> String:
	return str(FISH_RARITY_KEYS.get(value, "common"))
