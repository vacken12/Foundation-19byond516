/datum/map/site42

	post_round_safe_areas = list (
		/area/site42/surface/bunker
		)

/area/turbolift
	name = "\improper Turbolift"
	icon_state = "shuttle"
	requires_power = 0
	dynamic_lighting = 1
	area_flags = AREA_FLAG_RAD_SHIELDED

// SITE 42 ELEVATOR AREA'S

// SITE 42 TRAM AREA'S

// SITE 42 SURFACE AREA'S

/area/site42
	base_turf = /turf/simulated/floor/plating

/area/site42/surface/surface
	name = "Surface"
	//requires_power = 0
	//dynamic_lighting = 0

/area/site42/surface/surface/west
	name = "Surface West"
	requires_power = 0
	dynamic_lighting = 0

/area/site42/surface/bunker
	name = "\improper Secure Bunker"
	icon_state = "centcom"
	requires_power = 0
	dynamic_lighting = 1
	area_flags = AREA_FLAG_RAD_SHIELDED

// SITE 42 LCZ

/area/site42/lcz/hallways
	name = "\improper Light Containment Hallway"
	icon_state = "hallC1"
	area_flags = AREA_FLAG_RAD_SHIELDED
	sound_env = LARGE_ENCLOSED
	forced_ambience = list(
	'sounds/ambience/lcz/crb/alarm.ogg'
	)
	ambience = list(
	'sounds/ambience/lcz/general/Ambient1.ogg',
	'sounds/ambience/lcz/general/Ambient2.ogg',
	'sounds/ambience/lcz/general/Ambient3.ogg',
	'sounds/ambience/lcz/general/Ambient4.ogg',
	'sounds/ambience/lcz/general/Ambient5.ogg',
	'sounds/ambience/lcz/general/Ambient6.ogg',
	'sounds/ambience/lcz/general/Ambient7.ogg',
	'sounds/ambience/lcz/general/Ambient8.ogg',
	'sounds/ambience/lcz/general/Ambient9.ogg',
	)

/area/site42/lcz/entrance_checkpoint_north
	name = "\improper Light Containment Zone Checkpoint North"
	area_flags = AREA_FLAG_RAD_SHIELDED
	icon_state = "checkpoint1"

/area/site42/lcz/entrance_checkpoint_south
	name = "\improper Light Containment Zone Checkpoint South"
	area_flags = AREA_FLAG_RAD_SHIELDED
	icon_state = "checkpoint1"

/area/site42/lcz/restroom_north
	name = "\improper Restroom North"
	icon_state = "conference"
	area_flags = AREA_FLAG_RAD_SHIELDED
	sound_env = SMALL_ENCLOSED

/area/site42/lcz/restroom_south
	name = "\improper Restroom South"
	icon_state = "conference"
	area_flags = AREA_FLAG_RAD_SHIELDED
	sound_env = SMALL_ENCLOSED

/area/site42/lcz/office
	name = "\improper Light Containment Office"
	icon_state = "conference"
	area_flags = AREA_FLAG_RAD_SHIELDED
	sound_env = SMALL_ENCLOSED

/area/site42/lcz/canteen
	name = "\improper Light Containment Canteen"
	area_flags = AREA_FLAG_RAD_SHIELDED
	icon_state = "kitchen"

// Sci

/area/site42/lcz/scp173
	name = "\improper SCP-173"
	icon_state = "research"
	area_flags = AREA_FLAG_RAD_SHIELDED
	sound_env = SMALL_ENCLOSED

/area/site42/lcz/scp914
	name = "\improper SCP-914"
	icon_state = "research"
	area_flags = AREA_FLAG_RAD_SHIELDED
	sound_env = SMALL_ENCLOSED

/area/site42/lcz/scp999
	name = "\improper SCP-999"
	icon_state = "research"
	area_flags = AREA_FLAG_RAD_SHIELDED
	sound_env = SMALL_ENCLOSED

/area/site42/lcz/scp529
	name = "\improper SCP-529"
	icon_state = "research"
	area_flags = AREA_FLAG_RAD_SHIELDED
	sound_env = SMALL_ENCLOSED

/area/site42/lcz/scp151
	name = "\improper SCP-151"
	icon_state = "research"
	area_flags = AREA_FLAG_RAD_SHIELDED
	sound_env = SMALL_ENCLOSED

/area/site42/lcz/scp012
	name = "\improper SCP-012"
	icon_state = "research"
	area_flags = AREA_FLAG_RAD_SHIELDED
	sound_env = SMALL_ENCLOSED

/area/site42/lcz/scp216
	name = "\improper SCP-216"
	icon_state = "research"
	area_flags = AREA_FLAG_RAD_SHIELDED
	sound_env = SMALL_ENCLOSED

/area/site42/lcz/scp513
	name = "\improper SCP-513"
	icon_state = "research"
	area_flags = AREA_FLAG_RAD_SHIELDED
	sound_env = SMALL_ENCLOSED

/area/site42/lcz/scp066
	name = "\improper SCP-066"
	icon_state = "research"
	area_flags = AREA_FLAG_RAD_SHIELDED
	sound_env = SMALL_ENCLOSED

/area/site42/lcz/items_storage_vault
	name = "\improper Items Storage Vault"
	icon_state = "research"
	area_flags = AREA_FLAG_RAD_SHIELDED
	sound_env = SMALL_ENCLOSED

// D-CLASS

/area/site42/lcz/dclass/checkpoint
	name = "\improper CDCZ Entrance Checkpoint"
	area_flags = AREA_FLAG_RAD_SHIELDED
	icon_state = "checkpoint"

/area/site42/lcz/dclass/cells
	name = "\improper CDCZ Cells"
	area_flags = AREA_FLAG_RAD_SHIELDED
	icon_state = "Sleep"

/area/site42/lcz/dclass/isolation
	name = "\improper CDCZ Isolation"
	area_flags = AREA_FLAG_RAD_SHIELDED
	icon_state = "Sleep"

// ENGI

/area/site42/engineering/atmos
	name = "\improper Atmospherics"
	icon_state = "atmos"
	area_flags = AREA_FLAG_RAD_SHIELDED

// MED

/area/site42/medical/infirmreception
	name = "\improper Infirmary Reception"
	icon_state = "medbay2"
	ambience = list('sounds/ambience/signal.ogg')
	area_flags = AREA_FLAG_RAD_SHIELDED

/area/site42/medical/infirmary
	name = "\improper Infirmary Hallway"
	icon_state = "medbay"
	area_flags = AREA_FLAG_RAD_SHIELDED

/area/site42/medical/exam_room
	name = "\improper Exam Room"
	icon_state = "exam_room"
	area_flags = AREA_FLAG_RAD_SHIELDED

/area/site42/medical/chemistry
	name = "\improper Chemistry"
	icon_state = "chem"
	area_flags = AREA_FLAG_RAD_SHIELDED

/area/site42/medical/surgery/op1
	name = "\improper Operating Theatre #1"
	icon_state = "surgery"
	area_flags = AREA_FLAG_RAD_SHIELDED

/area/site42/medical/surgery/op2
	name = "\improper Operating Theatre #2"
	icon_state = "surgery"
	area_flags = AREA_FLAG_RAD_SHIELDED

/area/site42/medical/surgery/hall
	name = "\improper Surgical Hallway"
	icon_state = "surgery"
	area_flags = AREA_FLAG_RAD_SHIELDED

/area/site42/medical/equipstorage
	name = "\improper Equipment Storage"
	icon_state = "medbay4"
	ambience = list('sounds/ambience/signal.ogg')
	area_flags = AREA_FLAG_RAD_SHIELDED


// SITE 42 HCZ

/area/site42/hcz/hallways
	name = "\improper HCZ Hallways"
	icon_state = "fpmaint"
	area_flags = AREA_FLAG_RAD_SHIELDED

// Sci

/area/site42/hcz/scp106containment
	name = "\improper SCP-106 Containment Chamber"
	icon_state = "research"
	area_flags = AREA_FLAG_RAD_SHIELDED

/area/site42/hcz/scp049containment
	name = "\improper SCP-049 Containment Chamber"
	icon_state = "research"
	area_flags = AREA_FLAG_RAD_SHIELDED
	ambience = list('sounds/ambience/hcz/049/Room049.ogg')

/area/site42/hcz/scp280containment
	name = "\improper SCP-280 Containment Chamber"
	icon_state = "research"
	area_flags = AREA_FLAG_RAD_SHIELDED

/area/site42/hcz/scp096containment
	name = "\improper SCP-096 Containment Chamber"
	icon_state = "research"
	area_flags = AREA_FLAG_RAD_SHIELDED

/area/site42/hcz/scp8containment
	name = "\improper SCP-008 Containment Chamber"
	icon_state = "research"
	area_flags = AREA_FLAG_RAD_SHIELDED

/area/site42/hcz/scp457containment
	name = "\improper SCP-457 Containment Chamber"
	icon_state = "research"
	area_flags = AREA_FLAG_RAD_SHIELDED

/area/site42/hcz/scp2427containment
	name = "\improper SCP-2427-3 Containment Chamber"
	icon_state = "research"
	area_flags = AREA_FLAG_RAD_SHIELDED

/area/site42/hcz/scp343containment
	name = "\improper SCP-343 Containment Chamber"
	icon_state = "research"
	area_flags = AREA_FLAG_RAD_SHIELDED

