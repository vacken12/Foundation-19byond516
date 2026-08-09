#define SCP004_EFFECT_GIB    0
#define SCP004_EFFECT_PORTAL 1

// ==================== SCP-004 DOOR ====================
/obj/structure/scp004_door
	name = "heavy wooden door"
	desc = "A heavy wooden door bound with iron hinges."
	icon = 'icons/SCP/scp-004.dmi'
	icon_state = "door_closed"
	density = TRUE
	anchored = TRUE
	opacity = TRUE
	var/open = FALSE
	var/door_opening = FALSE
	var/door_closing = FALSE
	var/portal_active = FALSE
	var/obj/effect/portal/scp004/current_portal = null
	var/obj/effect/portal/scp004/linked_portal = null
	var/portal_timer = null

/obj/structure/scp004_door/Initialize(mapload)
	. = ..()
	update_icon()

	SCP = new /datum/scp(
		src, // Ref to actual SCP atom
		"heavy wooden door", //Name (Should not be the scp desg, more like what it can be described as to viewers)
		SCP_EUCLID, //Obj Class
		"004", //Numerical Designation
	)

/obj/structure/scp004_door/Destroy()
	if(portal_timer)
		deltimer(portal_timer)
	QDEL_NULL(current_portal)
	QDEL_NULL(linked_portal)
	return ..()

/obj/structure/scp004_door/attackby(obj/item/W, mob/user, params)
	if(!istype(W, /obj/item/key/scp004))
		return ..()
	if(door_opening || door_closing || portal_active || open)
		return
	var/obj/item/key/scp004/key = W
	try_key(user, key)

/obj/structure/scp004_door/proc/try_key(mob/user, obj/item/key/scp004/key)
	user.visible_message(
		SPAN_NOTICE("[user] inserts the key into the lock."),
		SPAN_NOTICE("You insert the key. The mechanism begins to turn with a heavy, grinding sound...")
	)
	if(!do_after(user, 2 SECONDS, src))
		return
	if(key.key_effect == SCP004_EFFECT_GIB)
		gib_user(user)
		return
	open_portal(key)

/obj/structure/scp004_door/proc/open_portal(obj/item/key/scp004/key)
	door_opening = TRUE
	open = TRUE
	portal_active = TRUE
	density = FALSE
	opacity = FALSE
	icon_state = "door_open"

	current_portal = new /obj/effect/portal/scp004(loc)
	current_portal.icon = 'icons/SCP/scp-004.dmi'
	current_portal.icon_state = "portal"
	current_portal.set_light(2, 1, "#88CCFF")

	var/turf/T = locate(key.portal_x, key.portal_y, key.portal_z)
	if(T)
		linked_portal = new /obj/effect/portal/scp004(T)
		linked_portal.icon = 'icons/SCP/scp-004.dmi'
		linked_portal.icon_state = "portal"
		linked_portal.set_light(2, 1, "#88CCFF")
		current_portal.linked = linked_portal
		linked_portal.linked = current_portal
		linked_portal.target_x = loc.x
		linked_portal.target_y = loc.y
		linked_portal.target_z = loc.z

	current_portal.target_x = key.portal_x
	current_portal.target_y = key.portal_y
	current_portal.target_z = key.portal_z

	door_opening = FALSE
	visible_message(SPAN_WARNING("The door swings open, revealing a shimmering passageway."))
	portal_timer = addtimer(CALLBACK(src, PROC_REF(auto_close_portal)), 1 MINUTES, TIMER_STOPPABLE)

/obj/structure/scp004_door/proc/auto_close_portal()
	visible_message(SPAN_NOTICE("The passageway flickers and vanishes. The door closes."))
	QDEL_NULL(current_portal)
	QDEL_NULL(linked_portal)
	portal_active = FALSE
	close_door()
	portal_timer = null

/obj/structure/scp004_door/proc/gib_user(mob/user)
	user.visible_message(SPAN_DANGER("[user]'s body is torn apart by an unseen force!"))
	user.gib(1, 1, 1)

/obj/structure/scp004_door/proc/close_door()
	if(door_closing)
		return
	door_closing = TRUE
	icon_state = "door_closing"
	addtimer(CALLBACK(src, PROC_REF(finish_close_door)), 1 SECONDS)

/obj/structure/scp004_door/proc/finish_close_door()
	door_closing = FALSE
	icon_state = "door_closed"
	open = FALSE
	density = TRUE
	opacity = TRUE
	update_icon()

/obj/structure/scp004_door/update_icon()
	icon_state = open ? "door_open" : "door_closed"

/obj/structure/scp004_door/examine(mob/user)
	. = ..()
	if(portal_active)
		. += SPAN_NOTICE("A shimmering passageway flickers in the doorway.")
	else if(open)
		. += SPAN_NOTICE("The door is open.")
	else
		. += SPAN_NOTICE("The door is locked.")

/obj/structure/scp004_door/attack_hand(mob/user)
	if(portal_active || door_closing)
		to_chat(user, SPAN_NOTICE("You need to wait for the door to close."))
	else if(open)
		to_chat(user, SPAN_NOTICE("The door is open."))
	else
		to_chat(user, SPAN_WARNING("The door is locked. A specific key is required."))

// ==================== SCP-004 KEYS ====================
/obj/item/key/scp004
	name = "rusted key"
	desc = "An old key with no identifying marks."
	icon = 'icons/SCP/scp-004.dmi'
	icon_state = "key_1"
	abstract_type = /obj/item/key/scp004
	w_class = ITEM_SIZE_TINY
	var/key_effect = SCP004_EFFECT_GIB
	var/key_id = 0
	var/portal_x = 0
	var/portal_y = 0
	var/portal_z = 0

/obj/item/key/scp004/Initialize(mapload)
	. = ..()
	update_icon()

/obj/item/key/scp004/update_icon()
	icon_state = "key_[key_id]"

/obj/item/key/scp004/examine(mob/user)
	. = ..()
	if(user.client?.holder)
		if(key_effect == SCP004_EFFECT_PORTAL)
			. += "<span class='admin'>ADMIN: Key #[key_id] — PORTAL ([portal_x],[portal_y],[portal_z])</span>"
		else
			. += "<span class='admin'>ADMIN: Key #[key_id] — GIB</span>"

/obj/item/key/scp004/key_1
	name = "rusted key I"
	key_id = 1
	icon_state = "key_1"
	key_effect = SCP004_EFFECT_PORTAL
	portal_x = 44
	portal_y = 47
	portal_z = 8

/obj/item/key/scp004/key_2
	name = "rusted key II"
	key_id = 2
	icon_state = "key_2"
	key_effect = SCP004_EFFECT_PORTAL
	portal_x = 32
	portal_y = 22
	portal_z = 5

/obj/item/key/scp004/key_3
	name = "rusted key III"
	key_id = 3
	icon_state = "key_3"
	key_effect = SCP004_EFFECT_PORTAL
	portal_x = 161
	portal_y = 181
	portal_z = 5

/obj/item/key/scp004/key_4
	name = "rusted key IV"
	key_id = 4
	icon_state = "key_4"
	key_effect = SCP004_EFFECT_PORTAL

/obj/item/key/scp004/key_5
	name = "rusted key V"
	key_id = 5
	icon_state = "key_5"

/obj/item/key/scp004/key_6
	name = "rusted key VI"
	key_id = 6
	icon_state = "key_6"
	key_effect = SCP004_EFFECT_PORTAL
	portal_x = 231
	portal_y = 117
	portal_z = 2

/obj/item/key/scp004/key_7
	name = "rusted key VII"
	key_id = 7
	icon_state = "key_7"

/obj/item/key/scp004/key_8
	name = "rusted key VIII"
	key_id = 8
	icon_state = "key_8"
	key_effect = SCP004_EFFECT_PORTAL

/obj/item/key/scp004/key_9
	name = "rusted key IX"
	key_id = 9
	icon_state = "key_9"

/obj/item/key/scp004/key_10
	name = "rusted key X"
	key_id = 10
	icon_state = "key_10"
	key_effect = SCP004_EFFECT_PORTAL

/obj/item/key/scp004/key_11
	name = "rusted key XI"
	key_id = 11
	icon_state = "key_11"
	key_effect = SCP004_EFFECT_PORTAL
	portal_x = 43
	portal_y = 130
	portal_z = 8

/obj/item/key/scp004/key_12
	name = "rusted key XII"
	key_id = 12
	icon_state = "key_12"
	key_effect = SCP004_EFFECT_PORTAL
	portal_x = 39
	portal_y = 189
	portal_z = 8

// ==================== SCP-004 PORTAL ====================
/obj/effect/portal/scp004
	name = "strange portal"
	desc = "A shimmering passageway."
	icon = 'icons/SCP/scp-004.dmi'
	icon_state = "portal"
	anchored = TRUE
	mouse_opacity = 1
	density = FALSE
	layer = 10
	var/target_x = 1
	var/target_y = 1
	var/target_z = 2
	var/obj/effect/portal/scp004/linked = null
	var/last_teleport_time = 0
	var/teleport_cooldown = 5

/obj/effect/portal/scp004/Destroy()
	if(linked && !QDELETED(linked))
		var/obj/effect/portal/scp004/L = linked
		linked = null
		L.linked = null
		qdel(L)
	return ..()

/obj/effect/portal/scp004/Crossed(atom/movable/AM)
	if(!isliving(AM))
		return
	if(world.time < last_teleport_time + teleport_cooldown)
		return
	var/mob/living/L = AM
	var/turf/T = locate(target_x, target_y, target_z)
	if(!T || T == loc)
		return
	last_teleport_time = world.time
	if(linked && !QDELETED(linked))
		linked.last_teleport_time = world.time
	L.forceMove(T)
	to_chat(L, SPAN_NOTICE("You step through the portal..."))

/obj/effect/portal/scp004/attack_hand(mob/user)
	return

#undef SCP004_EFFECT_GIB
#undef SCP004_EFFECT_PORTAL
