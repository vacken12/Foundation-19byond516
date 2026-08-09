// ==================== SCP-004 FLOOR ====================
/turf/simulated/floor/scp004
	name = "dimension floor"
	desc = "A cold, dark stone floor that seems to absorb light. The surface feels unnaturally smooth."
	icon = 'icons/SCP/scp-004.dmi'
	icon_state = "floor"

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
/obj/structure/flora/tree/dead
	name = "dead tree"
	icon = 'icons/obj/flora/deadtree96x96.dmi'
	icon_state = "dead"
	pixel_x = -16
	density = TRUE

/obj/structure/streetlight
	name = "streetlight"
	icon = 'icons/obj/streetlight.dmi'
	icon_state = "lamppost"
	pixel_w = -32
	anchored = TRUE
	density = TRUE
	var/light_on = TRUE
	light_color = "#ffde9b"

/obj/structure/streetlight/Initialize()
	. = ..()
	if(light_on)
		set_light(1, 1, 5)
