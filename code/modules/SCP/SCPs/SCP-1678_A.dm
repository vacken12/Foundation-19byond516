// ==================================================================
// SCP-1678-A - Masked Figure
// ==================================================================

/mob/living/carbon/human/scp1678
	name = "masked figure"
	desc = "An unnerving figure with fabric scraps covering its face."
	icon = 'icons/SCP/scp-1678.dmi'
	icon_state = null

	see_invisible = SEE_INVISIBLE_NOLIGHTING
	see_in_dark = 7
	status_flags = NO_ANTAG
	maxHealth = 200
	health = 200

	var/emote_cooldown = 5 SECONDS
	var/emote_cooldown_track = 0

/mob/living/carbon/human/scp1678/Initialize(mapload, new_species = "SCP-1678-A")
	. = ..()

	SCP = new /datum/scp(
		src,
		"masked figure",
		SCP_KETER,
		"1678-A",
		SCP_PLAYABLE
	)

	add_verb(src, list(
		/client/proc/scpooc,
		/mob/living/carbon/human/scp1678/verb/SayPhrase
	))

	add_language(LANGUAGE_ENGLISH, FALSE)
	add_language(LANGUAGE_EAL, FALSE)
	add_language(LANGUAGE_GUTTER, FALSE)

	SCP.min_time = 0
	SCP.min_playercount = 0

	if(!(MUTATION_XRAY in mutations))
		mutations.Add(MUTATION_XRAY)
		update_mutations()
		update_sight()

	queue_icon_update()

	REMOVE_TRAIT(src, TRAIT_HANDS_BLOCKED, STAT_TRAIT)
	REMOVE_TRAIT(src, TRAIT_CRITICAL_CONDITION, STAT_TRAIT)
	REMOVE_TRAIT(src, TRAIT_UI_BLOCKED, STAT_TRAIT)

// ==================================================================
// Icon rendering
// ==================================================================

/mob/living/carbon/human/scp1678/update_icons()
	return

/mob/living/carbon/human/scp1678/on_update_icon()
	if(lying || resting)
		var/matrix/M = matrix()
		transform = M.Turn(90)
	else
		transform = null
	return

// ==================================================================
// Stun and weakness immunity
// ==================================================================

/mob/living/carbon/human/scp1678/handle_stunned()
	if(stunned)
		stunned = 0
	return 0

/mob/living/carbon/human/scp1678/handle_weakened()
	if(weakened)
		weakened = 0
	return 0

/mob/living/carbon/human/scp1678/succumb()
	to_chat(src, SPAN_WARNING("You cannot succumb!"))
	return

/mob/living/carbon/human/scp1678/Life()
	. = ..()

	if(lying)
		lying = 0
	if(resting)
		resting = 0
	if(weakened)
		weakened = 0
	if(stunned)
		stunned = 0
	if(stat == UNCONSCIOUS)
		stat = CONSCIOUS

/mob/living/carbon/human/scp1678/get_pressure_weakness()
	return 0

/mob/living/carbon/human/scp1678/handle_breath()
	return 1

// ==================================================================
// Movement speed
// ==================================================================

/mob/living/carbon/human/scp1678/movement_delay(decl/move_intent/using_intent = move_intent)
	return 4.0

// ==================================================================
// Footstep sounds
// ==================================================================

/mob/living/carbon/human/scp1678/play_special_footstep_sound(turf/T, volume = 30, range = 1)
	playsound(T, 'sounds/effects/footstep/gravel1.ogg', max(20, volume), TRUE, range)
	return TRUE

// ==================================================================
// Speech
// ==================================================================

/mob/living/carbon/human/scp1678/say(message, datum/language/speaking = null, whispered)
	if(whispered)
		return ..()
	to_chat(src, SPAN_NOTICE("You cannot speak normally. Use 'Say Phrase' verb."))
	return 0

/mob/living/carbon/human/scp1678/verb/SayPhrase()
	set name = "Say Phrase"
	set category = "SCP-1678"
	set desc = "Speak one of your pre-defined phrases"

	if(stat == DEAD)
		return
	if(world.time < emote_cooldown_track)
		to_chat(src, SPAN_WARNING("You cannot speak yet. Wait [round((emote_cooldown_track - world.time) / 10)] seconds."))
		return

	var/list/phrases = list(
		"By order of the Watch, you are to be detained.",
		"Remain calm. Resistance will be met with force.",
		"Halt, citizen. Your papers are out of order.",
		"Step out of the shadows. Compliance is mandatory.",
		"You are in violation of the Public Decency Act."
	)
	var/selected_phrase = input(src, "Choose a phrase:", "SCP-1678 Phrases") as null|anything in phrases
	if(!selected_phrase)
		return

	playsound(src, 'sounds/scp/1678/whistle.ogg', 40, 1)
	visible_message(SPAN_DANGER("[src] utters in a metallic drone: '[selected_phrase]'"))
	emote_cooldown_track = world.time + emote_cooldown

// ==================================================================
// Death
// ==================================================================

/mob/living/carbon/human/scp1678/death(gibbed,deathmessage="disappeared into thin air...", show_dead_message = "You have died.")
	playsound(get_turf(src), 'sounds/scp/1678/whistle.ogg', 30, 1)
	qdel(src)

// ==================================================================
// Baton
// ==================================================================

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
	canremove = TRUE
