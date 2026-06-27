// ============================================================================
// SCP-860 - Blue Key
// ============================================================================

GLOBAL_LIST_EMPTY(scp860_return_spawns)

/obj/item/scp860
	name = "dark blue key"
	desc = "A dark blue key that feels cold to the touch. Numbers occasionally flicker across its surface."
	icon = 'icons/SCP/scp-860.dmi'
	icon_state = "key"
	item_state = "key"
	w_class = ITEM_SIZE_SMALL

	var/use_cooldown = 3 MINUTES
	var/use_cooldown_track = 0

	var/portal_x = 208
	var/portal_y = 181
	var/portal_z = 8

	var/return_x = 0
	var/return_y = 0
	var/return_z = 0
	var/has_return_coords = FALSE

/obj/item/scp860/Initialize(mapload)
	. = ..()
	SCP = new /datum/scp(
		src,
		"dark blue key",
		SCP_SAFE,
		"860"
	)

/obj/item/scp860/afterattack(atom/target, mob/user, proximity_flag)
	if(!proximity_flag)
		return

	if(world.time < use_cooldown_track)
		to_chat(user, SPAN_WARNING("[src] is not ready yet. Wait [round((use_cooldown_track - world.time) / 600)] minutes."))
		return

	if(!istype(target, /obj/machinery/door) && !istype(target, /obj/structure/scp004_door) && !istype(target, /obj/structure/scp860_return_door))
		return

	if(istype(target, /obj/structure/scp860_return_door))
		var/obj/structure/scp860_return_door/RD = target
		if(has_return_coords)
			RD.target_x = return_x
			RD.target_y = return_y
			RD.target_z = return_z

			user.visible_message(
				SPAN_DANGER("[user] inserts [src] into [RD] and turns it..."),
				SPAN_DANGER("You insert [src] and begin turning...")
			)
			playsound(get_turf(user), pick('sounds/effects/clue1.ogg', 'sounds/effects/clue2.ogg'), 50, TRUE)

			if(!do_after(user, 2 SECONDS, RD, bonus_percentage = 50))
				return

			RD.icon_state = "metalopen"
			playsound(get_turf(user), 'sounds/effects/teleport1.ogg', 50, TRUE)

			var/turf/T = locate(RD.target_x, RD.target_y, RD.target_z)
			if(T)
				user.forceMove(T)
				to_chat(user, SPAN_NOTICE("You step through and return to where you came from."))
			else
				to_chat(user, SPAN_WARNING("The doorway leads nowhere..."))

			visible_message(SPAN_WARNING("[RD] fades away."))
			qdel(RD)
			use_cooldown_track = world.time + use_cooldown
		else
			to_chat(user, SPAN_WARNING("[src] doesn't know the way back yet."))
		return

	if(istype(target, /obj/machinery/door))
		var/obj/machinery/door/D = target
		if(!D.density)
			to_chat(user, SPAN_WARNING("[D] is already open."))
			return

	if(istype(target, /obj/structure/scp004_door))
		var/obj/structure/scp004_door/D = target
		if(D.open || D.portal_active)
			to_chat(user, SPAN_WARNING("[D] is already open."))
			return

	user.visible_message(
		SPAN_DANGER("[user] inserts [src] into [target] and begins turning it..."),
		SPAN_DANGER("You insert [src] into [target]. The lock clicks...")
	)

	playsound(get_turf(user), pick('sounds/effects/clue1.ogg', 'sounds/effects/clue2.ogg'), 50, TRUE)

	// Delay for lock turning
	if(!do_after(user, 2 SECONDS, target, bonus_percentage = 50))
		return

	return_x = user.x
	return_y = user.y
	return_z = user.z
	has_return_coords = TRUE

	use_cooldown_track = world.time + use_cooldown

	// Open the door
	if(istype(target, /obj/machinery/door))
		var/obj/machinery/door/D = target
		D.open(1)

	if(istype(target, /obj/structure/scp004_door))
		var/obj/structure/scp004_door/D = target
		D.icon_state = "door_open"
		D.open = TRUE
		D.density = FALSE
		D.opacity = FALSE

	var/obj/effect/portal/scp860_entry/P = new(get_turf(target))
	P.target_x = portal_x
	P.target_y = portal_y
	P.target_z = portal_z

	user.visible_message(
		SPAN_DANGER("The doorway flickers and a dark forest appears beyond!"),
		SPAN_DANGER("A passage opens... The key remembers this spot.")
	)

/obj/item/scp860/examine(mob/user)
	. = ..()
	if(has_return_coords)
		to_chat(user, SPAN_NOTICE("The key remembers: [return_x], [return_y], [return_z]."))
	to_chat(user, SPAN_NOTICE("Destination: [portal_x], [portal_y], [portal_z]."))

// ============================================================================
// SCP-860 ENTRY PORTAL
// ============================================================================

/obj/effect/portal/scp860_entry
	name = "dark portal"
	desc = "A shimmering passageway leading to an unknown forest."
	icon = 'icons/SCP/scp-860.dmi'
	icon_state = "portal"
	anchored = TRUE
	mouse_opacity = 1
	density = FALSE
	layer = 10
	var/target_x = 1
	var/target_y = 1
	var/target_z = 2
	var/last_teleport_time = 0
	var/teleport_cooldown = 5
	var/portal_lifetime = 60 SECONDS
	var/door_spawned = FALSE

/obj/effect/portal/scp860_entry/Initialize(mapload)
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(close_portal)), portal_lifetime)

/obj/effect/portal/scp860_entry/proc/close_portal()
	visible_message(SPAN_WARNING("[src] flickers and vanishes."))
	qdel(src)

/obj/effect/portal/scp860_entry/Crossed(atom/movable/AM)
	if(!isliving(AM))
		return
	if(world.time < last_teleport_time + teleport_cooldown)
		return
	var/mob/living/L = AM
	var/turf/T = locate(target_x, target_y, target_z)
	if(!T || T == loc)
		return
	last_teleport_time = world.time
	playsound(loc, 'sounds/effects/teleport1.ogg', 50, TRUE)
	L.forceMove(T)
	to_chat(L, SPAN_NOTICE("You step through the portal into a dark forest..."))

	if(!door_spawned)
		door_spawned = TRUE
		spawn_return_door()

/obj/effect/portal/scp860_entry/proc/spawn_return_door()
	if(!LAZYLEN(GLOB.scp860_return_spawns))
		return

	var/turf/spawn_turf = pick(GLOB.scp860_return_spawns)
	new /obj/structure/scp860_return_door(spawn_turf)
	visible_message(SPAN_WARNING("A strange metal door materializes in the forest!"))

/obj/effect/portal/scp860_entry/attack_hand(mob/user)
	return

// ============================================================================
// SCP-860 RETURN DOOR
// ============================================================================

/obj/structure/scp860_return_door
	name = "metal door"
	desc = "A mysterious metal door standing alone. A faint blue light glows around its frame. It has no handle — only a keyhole."
	icon = 'icons/obj/doors/material_doors.dmi'
	icon_state = "metal"
	density = TRUE
	anchored = TRUE
	opacity = TRUE
	var/target_x = 0
	var/target_y = 0
	var/target_z = 0

/obj/structure/scp860_return_door/attack_hand(mob/user)
	to_chat(user, SPAN_WARNING("[src] has no handle. It can only be opened with the key."))

/obj/structure/scp860_return_door/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/scp860))
		return
	..()

// ============================================================================
// SCP-860-1 HAZARDOUS SMOKE
// ============================================================================

/obj/effect/scp860_smoke
	name = "strange smoke"
	desc = "A thick, blue-tinted smoke that burns the skin and clouds the mind."
	icon = 'icons/effects/effects.dmi'
	icon_state = "smoke"
	anchored = TRUE
	mouse_opacity = 0
	layer = ABOVE_HUMAN_LAYER
	alpha = 180
	var/last_damage_time = 0
	var/damage_cooldown = 3 SECONDS

/obj/effect/scp860_smoke/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/effect/scp860_smoke/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/effect/scp860_smoke/Process()
	if(world.time < last_damage_time + damage_cooldown)
		return

	var/mob/living/carbon/human/H = locate() in get_turf(src)
	if(!H)
		return

	last_damage_time = world.time
	H.take_overall_damage(3, 0)
	H.adjustToxLoss(1)
	if(H.reagents)
		H.reagents.add_reagent(/datum/reagent/medicine/amnestics/classa, 0.5)

/obj/effect/scp860_smoke/Crossed(atom/movable/AM)
	if(ishuman(AM))
		var/mob/living/carbon/human/H = AM
		H.take_overall_damage(5, 0)
		H.adjustToxLoss(2)
		if(H.reagents)
			H.reagents.add_reagent(/datum/reagent/medicine/amnestics/classa, 3)

/obj/effect/scp860_smoke/attack_hand(mob/user)
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		to_chat(H, SPAN_DANGER("You reach into the smoke. It burns!"))
		H.take_overall_damage(8, 0)
		H.adjustToxLoss(3)
		if(H.reagents)
			H.reagents.add_reagent(/datum/reagent/medicine/amnestics/classa, 5)

// ============================================================================
// SCP-860 RETURN DOOR LANDMARK
// ============================================================================

/obj/effect/landmark/scp860_return
	name = "SCP-860 return door spawn"
	icon_state = "x3"
	invisibility = 101

/obj/effect/landmark/scp860_return/Initialize(mapload)
	. = ..()
	if(!mapload)
		return INITIALIZE_HINT_QDEL
	GLOB.scp860_return_spawns += loc
	return INITIALIZE_HINT_LATELOAD

/obj/effect/landmark/scp860_return/LateInitialize()
	return

// ============================================================================
// SCP-860-2 AI HOLDER
// ============================================================================

/datum/ai_holder/simple_animal/melee/scp860_2
	vision_range = 4
	mauling = TRUE

// ============================================================================
// SCP-860-2 SAY LIST
// ============================================================================

/datum/say_list/scp860_2
	emote_hear = list(
		"lets out a low, guttural growl",
		"emits a hollow, clicking sound",
		"breathes heavily, sounding like rustling leaves"
	)
	emote_see = list(
		"tilts its skull-like head",
		"scratches the ground with sharp claws",
		"stares with glowing yellow eyes"
	)
	speak = list()

// ============================================================================
// NATURAL WEAPON
// ============================================================================

/obj/item/natural_weapon/scp860_2_claws
	name = "sharp claws"
	attack_verb = list("slashes", "claws", "tears", "rips")
	hitsound = 'sounds/effects/footstep/wood1.ogg'
	damtype = BRUTE
	force = 25

// ============================================================================
// SCP-860-2 MONSTER
// ============================================================================

/mob/living/simple_animal/hostile/scp860_2
	name = "monstrous creature"
	desc = "A monstrous feline creature, his body looks like a tangle of many branches, and his eyes... his yellow hollow eyes..."
	icon = 'icons/SCP/scp-860_2.dmi'
	icon_state = "monster"
	icon_living = "monster"
	icon_dead = null
	pixel_x = -16
	default_pixel_x = -16

	maxHealth = 2000
	health = 2000
	movement_cooldown = 4
	attack_delay = 2

	see_invisible = SEE_INVISIBLE_NOLIGHTING
	see_in_dark = 10

	faction = "scp"
	response_help = "hesitantly reaches toward"
	response_disarm = "shoves against"
	response_harm = "strikes"
	attacktext = list("slashes", "claws", "tears", "rips")
	mob_size = MOB_LARGE

	status_flags = CANPUSH
	density = TRUE
	anchored = FALSE
	a_intent = "harm"
	natural_weapon = /obj/item/natural_weapon/scp860_2_claws

	ai_holder_type = /datum/ai_holder/simple_animal/melee/scp860_2
	say_list_type = /datum/say_list/scp860_2

	// Cooldowns
	var/sound_cooldown = 30 SECONDS
	var/sound_cooldown_track = 0
	var/leap_cooldown = 12 SECONDS
	var/leap_cooldown_track = 0
	var/leap_range = 5
	var/camouflage_cooldown = 10 SECONDS
	var/camouflage_cooldown_track = 0
	var/camouflage_active = FALSE
	var/aiming_mode = FALSE

	// Sounds
	var/list/human_sounds = list(
		'sounds/scp/860/whisper1.ogg',
		'sounds/scp/860/whisper2.ogg',
		'sounds/scp/860/whisper3.ogg',
		'sounds/scp/860/whisper4.ogg',
		'sounds/scp/860/cry.ogg',
		'sounds/scp/860/scream_m.ogg',
		'sounds/scp/860/scream_f.ogg'
	)

	var/list/attack_sounds = list(
		'sounds/effects/footstep/wood1.ogg',
		'sounds/effects/footstep/wood2.ogg',
		'sounds/effects/footstep/wood3.ogg',
		'sounds/effects/footstep/wood4.ogg',
		'sounds/effects/footstep/wood5.ogg'
	)

/mob/living/simple_animal/hostile/scp860_2/Initialize(mapload)
	. = ..()
	SCP = new /datum/scp(
		src,
		"monstrous creature",
		SCP_EUCLID,
		"860-2",
		SCP_PLAYABLE|SCP_ROLEPLAY
	)

	add_verb(src, list(
		/mob/living/simple_animal/hostile/scp860_2/verb/Emit_Human_Sound,
		/mob/living/simple_animal/hostile/scp860_2/verb/Leap,
		/mob/living/simple_animal/hostile/scp860_2/verb/Toggle_Camouflage
	))

	add_language(LANGUAGE_EAL, FALSE)
	add_language(LANGUAGE_GUTTER, FALSE)
	add_language(LANGUAGE_ENGLISH, FALSE)

// Звук шагов
/mob/living/simple_animal/hostile/scp860_2/Move()
	. = ..()
	if(. && isturf(loc))
		playsound(loc, pick('sounds/effects/footstep/grass1.ogg','sounds/effects/footstep/grass2.ogg','sounds/effects/footstep/grass3.ogg','sounds/effects/footstep/grass4.ogg'), 20, TRUE)

// Атака
/mob/living/simple_animal/hostile/scp860_2/UnarmedAttack(atom/A, proximity_flag)
	if(!proximity_flag)
		return
	if(isliving(A))
		var/mob/living/L = A
		if(L.stat != DEAD)
			do_attack_animation(A)
			playsound(L, pick(attack_sounds), 50, TRUE)
			L.apply_damage(rand(25, 35), BRUTE)
			if(ishuman(L))
				to_chat(L, SPAN_DANGER("[src] slashes you with its claws!"))
			return
	..()

// === 1. ЧЕЛОВЕЧЕСКИЕ ЗВУКИ ===
/mob/living/simple_animal/hostile/scp860_2/verb/Emit_Human_Sound()
	set name = "Emit Human Sound"
	set category = "Abilities"
	set desc = "Produce a human-like sound to lure prey"

	if(stat == DEAD)
		return
	if(world.time < sound_cooldown_track)
		to_chat(src, SPAN_WARNING("You cannot produce another sound yet. Wait [round((sound_cooldown_track - world.time) / 10)] seconds."))
		return

	var/chosen_sound = pick(human_sounds)
	var/list/nearby_humans = list()
	for(var/mob/living/carbon/human/H in view(10, src))
		if(H != src && H.stat != DEAD)
			nearby_humans += H

	playsound(get_turf(src), chosen_sound, 50, FALSE, 10)
	for(var/mob/living/carbon/human/H in nearby_humans)
		if(findtext("[chosen_sound]", "whisper"))
			to_chat(H, SPAN_DANGER("You hear a faint whisper from the darkness."))
			H.adjust_hallucination(10)
		else if(findtext("[chosen_sound]", "cry"))
			to_chat(H, SPAN_WARNING("You hear someone sobbing in the distance."))
			H.adjust_hallucination(15)
		else if(findtext("[chosen_sound]", "scream"))
			to_chat(H, SPAN_DANGER("A blood-curdling scream echoes through the forest!"))
			H.adjust_hallucination(25)

	visible_message(SPAN_ITALIC("[src] produces an unsettling sound that echoes through the forest."))
	sound_cooldown_track = world.time

// === 2. РЫВОК В ТОЧКУ ===
/mob/living/simple_animal/hostile/scp860_2/verb/Leap()
	set name = "Leap"
	set category = "Abilities"
	set desc = "Click on a tile to leap there, damaging anyone in the way"

	if(stat == DEAD)
		return
	if(world.time < leap_cooldown_track)
		to_chat(src, SPAN_WARNING("Leap is not ready yet! Wait [round((leap_cooldown_track - world.time) / 10)] seconds."))
		return

	aiming_mode = TRUE
	to_chat(src, SPAN_DANGER("Leap ready! Click on a tile to jump there."))

/mob/living/simple_animal/hostile/scp860_2/ClickOn(atom/A)
	if(aiming_mode)
		aiming_mode = FALSE
		perform_leap(A)
		return
	..()

/mob/living/simple_animal/hostile/scp860_2/proc/perform_leap(atom/target)
	var/turf/T = get_turf(target)
	if(!T || T.density)
		to_chat(src, SPAN_WARNING("Can't leap there!"))
		return

	if(get_dist(src, T) > leap_range)
		to_chat(src, SPAN_WARNING("Target too far away! Maximum range is [leap_range] tiles."))
		return

	leap_cooldown_track = world.time + leap_cooldown

	visible_message(SPAN_DANGER("[src] leaps through the air with terrifying speed!"))
	playsound(get_turf(src), pick(attack_sounds), 60, TRUE)

	// Перемещаем
	var/old_loc = src.loc
	src.forceMove(T)

	// Наносим урон всем в точке приземления и по пути
	var/list/affected = list()
	for(var/mob/living/carbon/human/H in range(0, T))
		if(H != src && H.stat != DEAD)
			affected += H

	// Наносим урон
	for(var/mob/living/carbon/human/H in affected)
		H.apply_damage(20, BRUTE)
		H.Weaken(3)
		to_chat(H, SPAN_DANGER("[src] crashes into you!"))
		playsound(get_turf(H), pick(attack_sounds), 50, TRUE)

	// Если путь был длинным, проходим по линии и бьём дополнительно
	var/list/intermediate = getline(old_loc, T)
	for(var/turf/inter in intermediate)
		if(inter == old_loc || inter == T) continue
		for(var/mob/living/carbon/human/H in inter)
			if(H != src && H.stat != DEAD && !(H in affected))
				H.apply_damage(15, BRUTE)
				H.Weaken(2)
				to_chat(H, SPAN_DANGER("[src] crashes into you during the leap!"))
				affected += H

// === 3. МАСКИРОВКА ===
/mob/living/simple_animal/hostile/scp860_2/verb/Toggle_Camouflage()
	set name = "Toggle Camouflage"
	set category = "Abilities"
	set desc = "Merge with the environment, becoming nearly invisible except for your glowing eyes"

	if(stat == DEAD)
		return
	if(!camouflage_active && world.time < camouflage_cooldown_track)
		to_chat(src, SPAN_WARNING("Camouflage is on cooldown! Wait [round((camouflage_cooldown_track - world.time) / 10)] seconds."))
		return

	if(camouflage_active)
		camouflage_active = FALSE
		alpha = 255
		icon_state = "monster"
		to_chat(src, SPAN_NOTICE("You emerge from the shadows."))
	else
		camouflage_active = TRUE
		icon_state = "eyes"
		alpha = 80
		to_chat(src, SPAN_DANGER("You blend into the surroundings. Only your eyes remain visible."))
		camouflage_cooldown_track = world.time + camouflage_cooldown

// === 4. НЕ МОЖЕТ ГОВОРИТЬ ===
/mob/living/simple_animal/hostile/scp860_2/say(message, datum/language/speaking = null, whispering)
	to_chat(src, SPAN_NOTICE("You cannot speak."))
	return 0

// === 5. СМЕРТЬ — ИСЧЕЗАЕТ ===
/mob/living/simple_animal/hostile/scp860_2/death(gibbed)
	visible_message(SPAN_DANGER("[src] crumbles into dust and vanishes!"))
	playsound(get_turf(src), pick(attack_sounds), 50, TRUE)
	qdel(src)
