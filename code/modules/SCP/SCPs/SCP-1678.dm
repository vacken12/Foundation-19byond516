// ==================================================================
// SCP-1678-E - Actor
// ==================================================================

/mob/living/carbon/human/scp1678e
	name = "actor"
	desc = "A figure in a black suit and mask. It stands perfectly still, watching."
	icon = 'icons/SCP/scp-1678.dmi'
	icon_state = "actor"
	status_flags = NO_ANTAG

/mob/living/carbon/human/scp1678e/Initialize(mapload, new_species = "SCP-1678-E")
	. = ..(mapload, new_species)
	SCP = new /datum/scp(
		src,
		"actor",
		SCP_EUCLID,
		"1678-E",
		SCP_PLAYABLE|SCP_ROLEPLAY
	)
	add_verb(src, /client/proc/scpooc)
	SCP.min_time = 0
	SCP.min_playercount = 0

/mob/living/carbon/human/scp1678e/Life()
	. = ..()
	if(lying) lying = 0
	if(resting) resting = 0

/mob/living/carbon/human/scp1678e/update_sight()
	. = ..()
	see_in_dark = 7
	see_invisible = SEE_INVISIBLE_NOLIGHTING

/mob/living/carbon/human/scp1678e/update_icons()
	return

/mob/living/carbon/human/scp1678e/on_update_icon()
	if(lying || resting)
		var/matrix/M = matrix()
		transform = M.Turn(90)
	else
		transform = null

/mob/living/carbon/human/scp1678e/movement_delay(decl/move_intent/using_intent = move_intent)
	return 3.0

/mob/living/carbon/human/scp1678e/say(message, datum/language/speaking = null, whispering)
	return ..(message, speaking, whispering)

/mob/living/carbon/human/scp1678e/play_special_footstep_sound(turf/T, volume = 30, range = 1)
	playsound(T, 'sounds/effects/footstep/gravel1.ogg', max(20, volume), TRUE, range)
	return TRUE

/mob/living/carbon/human/scp1678e/death(gibbed, deathmessage = "collapses into a heap of black fabric...", show_dead_message = "You have died.")
	qdel(src)

// ==================================================================
// SCP-1678-A - Masked Figure
// ==================================================================

/mob/living/carbon/human/scp1678a
	name = "masked figure"
	desc = "An unnerving figure with fabric scraps covering its face."
	icon = 'icons/SCP/scp-1678-A.dmi'
	icon_state = null
	see_invisible = SEE_INVISIBLE_NOLIGHTING
	see_in_dark = 7
	status_flags = NO_ANTAG

	var/emote_cooldown = 5 SECONDS
	var/emote_cooldown_track = 0

/mob/living/carbon/human/scp1678a/Initialize(mapload, new_species = "SCP-1678-A")
	. = ..(mapload, new_species)
	SCP = new /datum/scp(
		src,
		"masked figure",
		SCP_KETER,
		"1678-A",
		SCP_PLAYABLE
	)
	add_verb(src, /client/proc/scpooc)
	add_verb(src, /mob/living/carbon/human/scp1678a/verb/Whistle)
	add_language(LANGUAGE_ENGLISH, FALSE)
	add_language(LANGUAGE_EAL, FALSE)
	add_language(LANGUAGE_GUTTER, FALSE)
	SCP.min_time = 0
	SCP.min_playercount = 0
	REMOVE_TRAIT(src, TRAIT_HANDS_BLOCKED, STAT_TRAIT)
	REMOVE_TRAIT(src, TRAIT_CRITICAL_CONDITION, STAT_TRAIT)
	REMOVE_TRAIT(src, TRAIT_UI_BLOCKED, STAT_TRAIT)

/mob/living/carbon/human/scp1678a/Life()
	. = ..()
	if(lying) lying = 0
	if(resting) resting = 0
	if(weakened) weakened = 0
	if(stunned) stunned = 0
	if(paralysis) paralysis = 0
	if(stat == UNCONSCIOUS) stat = CONSCIOUS
	if(HAS_TRAIT(src, TRAIT_CRITICAL_CONDITION))
		REMOVE_TRAIT(src, TRAIT_CRITICAL_CONDITION, STAT_TRAIT)
	if(HAS_TRAIT(src, TRAIT_HANDS_BLOCKED))
		REMOVE_TRAIT(src, TRAIT_HANDS_BLOCKED, STAT_TRAIT)

/mob/living/carbon/human/scp1678a/update_sight()
	. = ..()
	see_in_dark = 7
	see_invisible = SEE_INVISIBLE_NOLIGHTING

/mob/living/carbon/human/scp1678a/update_icons()
	return

/mob/living/carbon/human/scp1678a/on_update_icon()
	if(lying || resting)
		var/matrix/M = matrix()
		transform = M.Turn(90)
	else
		transform = null

/mob/living/carbon/human/scp1678a/handle_stunned()
	stunned = 0
	return 0

/mob/living/carbon/human/scp1678a/handle_weakened()
	weakened = 0
	return 0

/mob/living/carbon/human/scp1678a/get_pressure_weakness()
	return 0

/mob/living/carbon/human/scp1678a/handle_breath()
	return 1

/mob/living/carbon/human/scp1678a/movement_delay(decl/move_intent/using_intent = move_intent)
	return 4.0

/mob/living/carbon/human/scp1678a/play_special_footstep_sound(turf/T, volume = 30, range = 1)
	playsound(T, 'sounds/effects/footstep/gravel1.ogg', max(20, volume), TRUE, range)
	return TRUE

/mob/living/carbon/human/scp1678a/say(message, datum/language/speaking = null, whispering)
	if(whispering)
		return ..(message, speaking, whispering)
	to_chat(src, SPAN_NOTICE("You cannot speak normally. Use the 'Whistle' verb."))
	return

/mob/living/carbon/human/scp1678a/verb/Whistle()
	set name = "Whistle"
	set category = "SCP-1678"
	set desc = "Emit an eerie whistle"

	if(stat == DEAD)
		return
	if(world.time < emote_cooldown_track)
		to_chat(src, SPAN_WARNING("You cannot whistle yet. Wait [round((emote_cooldown_track - world.time) / 10)] seconds."))
		return

	playsound(src, 'sounds/scp/1678/whistle.ogg', 40, 1)
	visible_message(SPAN_DANGER("[src] emits an eerie whistle."))
	emote_cooldown_track = world.time + emote_cooldown

/mob/living/carbon/human/scp1678a/death(gibbed, deathmessage = "disappeared into thin air...", show_dead_message = "You have died.")
	playsound(get_turf(src), 'sounds/scp/1678/whistle.ogg', 30, 1)
	qdel(src)

/obj/item/melee/scp1678
	name = "ornate baton"
	desc = "A heavy, silver-colored baton."
	icon = 'icons/obj/weapons/melee_physical.dmi'
	icon_state = "metalbat0"
	item_state = "metalbat0"
	force = 20
	throwforce = 7
	w_class = ITEM_SIZE_NORMAL
	slot_flags = SLOT_BELT
	attack_verb = list("smashed", "beaten", "slammed", "struck", "battered", "bonked")
	hitsound = 'sounds/weapons/genhit3.ogg'
