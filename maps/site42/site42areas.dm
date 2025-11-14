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

// Fix for blob, vines and other, which use types from site 53 anyway
/*
/area/pocketdimension
	name = "Pocket Dimension"
	requires_power = 0
	dynamic_lighting = 0

/area/site53/ulcz/maintenance
	name = "Upper Light Containment Maintenance"
	icon_state = "maint_security_starboard"
	area_flags = AREA_FLAG_RAD_SHIELDED
	sound_env = TUNNEL_ENCLOSED
	turf_initializer = /decl/turf_initializer/maintenance

/area/site53/lhcz/maintenance
	name = "\improper Lower Heavy Containment Maintenance"
	icon_state = "fpmaint"
	area_flags = AREA_FLAG_RAD_SHIELDED
	turf_initializer = /decl/turf_initializer/maintenance

/area/site53/uez/maintenance
	name = "UEZ Maintenance"
	icon_state = "SolarcontrolS"
	turf_initializer = /decl/turf_initializer/maintenance

/area/site53/lhcz/maintenance
	name = "\improper Lower Heavy Containment Maintenance"
	icon_state = "fpmaint"
	area_flags = AREA_FLAG_RAD_SHIELDED
	turf_initializer = /decl/turf_initializer/maintenance

/area/site53/engineering/maintenance/maintenancetunnel
	name = "\improper Engineering Maintenance Tunnels"
	icon_state = "conference"
	area_flags = AREA_FLAG_RAD_SHIELDED
	turf_initializer = /decl/turf_initializer/maintenance

/area/site53/engineering/maintenance/llczmaint
	name = "\improper Lower Light Containment Maintenance Tunnels"
	icon_state = "conference"
	area_flags = AREA_FLAG_RAD_SHIELDED
	turf_initializer = /decl/turf_initializer/maintenance

/area/site53/engineering/selfdestruct
	name = "\improper Self-Destruct Room"
	icon_state = "nuke_storage"

/area/site53/engineering/lowernukeladders
	name = "\improper Lower Self Destruct Ladders"
	icon_state = "nuke_storage"

/area/site53/engineering/uppernukeladders
	name = "\improper Upper Self Destruct Ladders"
	icon_state = "nuke_storage"

/area/site53/medical/mentalhealth/isolation
	name = "\improper Virology"
	icon_state = "medbay3"
	ambience = list('sounds/ambience/signal.ogg')
	area_flags = AREA_FLAG_RAD_SHIELDED

/area/site53/reswing/xenobiology
	name = "\improper Xenobiology Laboratory"
	icon_state = "research"
	area_flags = AREA_FLAG_RAD_SHIELDED

/area/site53/science/seniorresearchera
	name = "\improper Senior Researcher's Office A"
	icon_state = "research"

/area/site53/ulcz/hallways
	name = "\improper Upper Light Containment Hallway"
	icon_state = "hallC1"
	area_flags = AREA_FLAG_RAD_SHIELDED

/area/site53/llcz/hallways
	name = "\improper Lower Light Containment Hallway"
	icon_state = "hallC1"
	area_flags = AREA_FLAG_RAD_SHIELDED

/area/site53/uhcz/hallways
	name = "\improper HCZ Hallways"
	icon_state = "fpmaint"
	area_flags = AREA_FLAG_RAD_SHIELDED

/area/site53/lhcz/hallway
	name = "\improper Lower Heavy Containment Hallways"
	icon_state = "hallC3"
	area_flags = AREA_FLAG_RAD_SHIELDED
	sound_env = LARGE_ENCLOSED

/area/site53/uez/hallway
	name = "\improper Entrance Zone"
	area_flags = AREA_FLAG_RAD_SHIELDED
	icon_state = "hallC1"
	sound_env = LARGE_ENCLOSED

/area/site53/science/aicobservation
	name = "\improper AIC Observation"
	icon_state = "research"

/area/site53/science/aiccore
	name = "\improper AIC Core"
	icon_state = "research"

/area/site53/llcz/mine/unexplored
/area/site53/llcz/mine/explored
/area/site53/surface
/area/turbolift/site53/surface
/area/turbolift/site53/basement
/area/turbolift/site53/scp106obs
/area/turbolift/site53/scp106obs
/area/turbolift/site53/uhcz
/area/turbolift/site53/lhcz
/area/site53/tram/scpcar
/area/turbolift/site53/commstower
/area/turbolift/site53/scp106cont
/area/turbolift/site53/robotlwr
/area/turbolift/site53/robotupr
/area/turbolift/site53/gatea
/area/turbolift/site53/hub
/area/centcom/goc
/area/turbolift/site53/up082
/area/turbolift/site53/low82
*/
