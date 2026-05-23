// code/modules/SCP/SCPs/SCP-004_structures.dm

// ==================== SCP-004 FLOOR ====================
/turf/simulated/floor/scp004
	name = "dimension floor"
	desc = "A cold, dark stone floor that seems to absorb light. The surface feels unnaturally smooth."
	icon = 'icons/SCP/scp-004.dmi'
	icon_state = "floor"

/turf/simulated/floor/soil
	name = "rocky sand"
	icon = 'icons/turf/flooring/asteroid.dmi'
	icon_state = "asteroid"

/turf/simulated/floor/asphalt
	name = "asphalt"
	icon = 'icons/turf/flooring/misc.dmi'
	icon_state = "asphalt"

/turf/simulated/floor/sidewalk
	name = "sidewalk"
	icon = 'icons/turf/flooring/misc.dmi'
	icon_state = "sidewalk"

// ==================== SCP-004 DECALS ====================
/obj/effect/floor_decal/scp004/border
	name = "border"
	icon = 'icons/turf/flooring/decals.dmi'
	icon_state = "border"

/obj/effect/floor_decal/scp004/border_corner
	name = "border corner"
	icon = 'icons/turf/flooring/decals.dmi'
	icon_state = "border_corner"

/obj/effect/floor_decal/scp004/crosswalk
	name = "crosswalk"
	icon = 'icons/turf/flooring/decals.dmi'
	icon_state = "crosswalk"

/obj/effect/floor_decal/scp004/crosswalk_vert
	name = "crosswalk"
	icon = 'icons/turf/flooring/decals.dmi'
	icon_state = "crosswalk_vert"

/obj/effect/floor_decal/scp004/roadmark
	name = "road marking"
	icon = 'icons/turf/flooring/decals.dmi'
	icon_state = "markup"

/obj/effect/floor_decal/scp004/roadmark_vert
	name = "road marking"
	icon = 'icons/turf/flooring/decals.dmi'
	icon_state = "markup_vert"

// ==================== SCP-004 STRUCTURES ====================
/obj/structure/flora/tree/dead/scp004
	name = "dead tree"
	icon = 'icons/obj/flora/deadtree96x96.dmi'
	icon_state = "dead"

/obj/machinery/light/streetlight
	name = "streetlight"
	icon = 'icons/obj/streetlight.dmi'
	icon_state = "lamppost"
	base_state = "lamppost"
	light_type = /obj/item/light/bulb
	construct_type = /obj/machinery/light_construct/small
	on = TRUE

/obj/machinery/light/streetlight/Initialize()
	. = ..()
	icon_state = "lamppost"
	set_light(0.8, 1, 5, 2, "#fce8c4")
