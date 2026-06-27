// ==================================================================
// SCP-035 - Possessive Mask (FINAL)
// ==================================================================

// ==================================================================
// Вспомогательный прок
// ==================================================================

/proc/ishostof035(mob/living/L)
	if(!ishuman(L)) return FALSE
	var/mob/living/carbon/human/H = L
	return istype(H.wear_mask, /obj/item/clothing/mask/scp035)

// ==================================================================
// Goo
// ==================================================================

/obj/effect/decal/cleanable/scp035_goo
	name = "black liquid"
	desc = "A thick, black, corrosive substance."
	icon = 'icons/effects/effects.dmi'
	icon_state = "greenglow"
	color = "#1a1a1a"

	var/tentacle_time = 0
	var/has_tentacle = FALSE
	var/mob/living/carbon/human/grabbed = null
	var/grab_end_time = 0
	var/last_corrosion = 0

/obj/effect/decal/cleanable/scp035_goo/Initialize()
	. = ..()
	tentacle_time = world.time + 4 MINUTES
	last_corrosion = world.time
	START_PROCESSING(SSobj, src)

/obj/effect/decal/cleanable/scp035_goo/Process()
	if(!has_tentacle && world.time > tentacle_time)
		has_tentacle = TRUE
		icon = 'icons/SCP/scp-035.dmi'
		icon_state = "tentacle_under"

	if(grabbed)
		if(grabbed.stat == DEAD || get_turf(grabbed) != get_turf(src))
			release()
			return
		if(world.time > grab_end_time)
			release()
			return
		icon_state = "tentacle_act"
		grabbed.apply_damage(10, BURN)
		playsound(get_turf(src), 'sounds/effects/splat.ogg', 50, 1)
		spawn(2)
			if(src && has_tentacle)
				icon_state = "tentacle_under"
		return

	if(!has_tentacle && world.time > last_corrosion + 2 MINUTES)
		corrode()
		last_corrosion = world.time

/obj/effect/decal/cleanable/scp035_goo/proc/release()
	if(grabbed)
		grabbed.visible_message(SPAN_WARNING("\The [src] releases [grabbed]!"))
		grabbed.anchored = FALSE
		grabbed = null
	if(has_tentacle)
		icon_state = "tentacle_off"
		spawn(2)
			if(src && has_tentacle)
				icon_state = "tentacle_under"

/obj/effect/decal/cleanable/scp035_goo/proc/corrode()
	var/turf/T = get_turf(src)
	if(!T) return

	if(has_tentacle) return

	if(istype(T, /turf/simulated/wall))
		var/turf/simulated/wall/W = T
		visible_message(SPAN_DANGER("[W] crumbles from corrosion!"))
		W.dismantle_wall()
		return

	for(var/atom/A in T)
		if(A == src) continue

		if(istype(A, /obj/machinery/door))
			var/obj/machinery/door/D = A
			if(!D.density) continue
			if(istype(D, /obj/machinery/door/airlock))
				var/obj/machinery/door/airlock/AR = D
				AR.unlock(TRUE)
				AR.welded = FALSE
			D.set_broken(TRUE)
			D.open(TRUE)
			visible_message(SPAN_DANGER("[D] corrodes and unlocks!"))
			continue

		if(istype(A, /obj/structure/window))
			var/obj/structure/window/W = A
			W.shatter()
			visible_message(SPAN_DANGER("[W] shatters from corrosion!"))
			continue

		if(istype(A, /obj/structure) || (istype(A, /obj/item) && A.simulated))
			visible_message(SPAN_DANGER("[A] dissolves into nothing!"))
			qdel(A)
			continue

/obj/effect/decal/cleanable/scp035_goo/Crossed(mob/living/L)
	if(!ishuman(L)) return
	if(ishostof035(L)) return
	if(L.stat == DEAD) return

	L.apply_damage(15, BURN)
	to_chat(L, SPAN_DANGER("The black liquid burns your skin!"))

	if(has_tentacle && !grabbed)
		grabbed = L
		icon_state = "tentacle_act"
		L.visible_message(SPAN_DANGER("\The [src] grabs [L]!"))
		L.Stun(10)
		L.anchored = TRUE
		L.apply_damage(5, BURN)
		grab_end_time = world.time + 10 SECONDS
		spawn(2)
			if(src && has_tentacle)
				icon_state = "tentacle_under"

/obj/effect/decal/cleanable/scp035_goo/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

// ==================================================================
// Container
// ==================================================================

/obj/item/scp035_box
	name = "SCP-035 Containment Box"
	icon = 'icons/SCP/scp-035.dmi'
	icon_state = "box"
	w_class = ITEM_SIZE_NORMAL
	var/has_mask = FALSE

/obj/item/scp035_box/update_icon()
	icon_state = has_mask ? "in_box" : "box"

/obj/item/scp035_box/attack_self(mob/user)
	if(!has_mask)
		to_chat(user, SPAN_NOTICE("The box is empty."))
		return

	if(alert(user, "Are you sure you want to release SCP-035?", "Release Mask", "Yes", "No") == "No")
		return

	var/obj/item/clothing/mask/scp035/M = new /obj/item/clothing/mask/scp035(get_turf(user))
	user.put_in_active_hand(M)
	has_mask = FALSE
	update_icon()
	playsound(src, 'sounds/machines/bolts_up.ogg', 50, 1)
	to_chat(user, SPAN_WARNING("You open the box and pull out the mask!"))

/obj/item/scp035_box/afterattack(atom/target, mob/user, proximity_flag)
	if(!proximity_flag) return
	if(!istype(target, /obj/item/clothing/mask/scp035)) return
	if(ishuman(target.loc))
		to_chat(user, SPAN_WARNING("You cannot seal the mask while it is being worn!"))
		return
	qdel(target)
	has_mask = TRUE
	update_icon()
	playsound(src, 'sounds/machines/bolts_down.ogg', 50, 1)
	to_chat(user, SPAN_NOTICE("You seal the mask into the box."))

/obj/item/scp035_box/prefilled/Initialize()
	. = ..()
	has_mask = TRUE
	update_icon()

// ==================================================================
// Remains
// ==================================================================

/obj/item/remains/scp035
	name = "corroded remains"
	desc = "Blackened, corroded human remains."
	icon = 'icons/effects/blood.dmi'
	icon_state = "remains"
	color = "#1a1a1a"

/obj/item/remains/scp035/attack_hand(mob/user)
	new /obj/effect/decal/cleanable/ash(get_turf(src))
	qdel(src)

// ==================================================================
// Mask
// ==================================================================

/obj/item/clothing/mask/scp035
	name = "white mask"
	desc = "A white porcelain theatrical mask."
	icon = 'icons/SCP/scp-035.dmi'
	icon_state = "comedy_obj"
	body_parts_covered = FACE
	canremove = FALSE
	w_class = ITEM_SIZE_SMALL
	item_icons = list(slot_wear_mask_str = 'icons/SCP/scp-035.dmi')

	var/mask_type = "comedy"
	var/is_rotting = FALSE
	var/is_recovering = FALSE
	var/decay = 0
	var/decay_timer = 0
	var/last_goo = 0
	var/telepathy_cooldown = 0
	var/goo_cooldown = 0
	var/heal_cooldown = 0
	var/last_memetic_damage = 0
	var/memetic_damage_delay = 30 SECONDS

/obj/item/clothing/mask/scp035/Initialize()
	. = ..()
	SCP = new /datum/scp(src, "white mask", SCP_KETER, "035", SCP_MEMETIC)
	SCP.memeticFlags = MVISUAL | MAUDIBLE | MSYNCED
	SCP.memetic_proc = TYPE_PROC_REF(/obj/item/clothing/mask/scp035, memetic_effect)
	SCP.memetic_sounds = list('sounds/scp/860/whisper1.ogg','sounds/scp/860/whisper2.ogg','sounds/scp/860/whisper3.ogg','sounds/scp/860/whisper4.ogg')
	SCP.compInit()
	START_PROCESSING(SSobj, src)
	mask_type = pick("comedy", "tragedy")
	update_mask_icon()
	decay_timer = world.time + 2 MINUTES

/obj/item/clothing/mask/scp035/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/clothing/mask/scp035/proc/update_mask_icon()
	var/suffix = is_rotting ? "_rot" : ""
	icon_state = "[mask_type]_obj[suffix]"
	item_state = "[mask_type]_obj[suffix]"
	item_state_slots[slot_wear_mask_str] = "[mask_type][suffix]"
	if(ishuman(loc))
		var/mob/living/carbon/human/H = loc
		H.update_inv_wear_mask()

/obj/item/clothing/mask/scp035/proc/memetic_effect(mob/living/carbon/human/H)
	if(!H || H.stat == UNCONSCIOUS || !H.can_see(src)) return
	if(ishostof035(H) || H.SCP || istype(loc, /obj/item/scp035_box) || ishuman(loc)) return

	var/dist = get_dist(H, src)

	if(dist > 1 && dist <= 6)
		step_to(H, src)
		H.Stun(2)
		to_chat(H, SPAN_WARNING("You feel drawn to \the [src]..."))
		playsound(H, pick('sounds/scp/860/whisper1.ogg','sounds/scp/860/whisper2.ogg','sounds/scp/860/whisper3.ogg','sounds/scp/860/whisper4.ogg'), 30, 0, 7)

		if(world.time > last_memetic_damage + memetic_damage_delay)
			last_memetic_damage = world.time
			var/obj/item/organ/internal/brain/B = H.internal_organs_by_name[BP_BRAIN]
			if(B) B.damage = min(B.max_damage, B.damage + 10)
			to_chat(H, SPAN_ITALIC("<i>You feel your mind slowly slipping away...</i>"))

	if(dist == 1)
		try_attach(H)

/obj/item/clothing/mask/scp035/proc/try_attach(mob/living/carbon/human/H)
	if(!H || H.SCP || ishostof035(H) || H.wear_mask == src) return
	if(H.wear_mask) H.drop_from_inventory(H.wear_mask)
	H.equip_to_slot(src, slot_wear_mask)
	visible_message(SPAN_DANGER("\The [src] latches onto [H]'s face!"))
	playsound(get_turf(H), 'sounds/effects/splat.ogg', 50, 1)
	on_equipped(H)

/obj/item/clothing/mask/scp035/attack_hand(mob/user)
	if(is_recovering)
		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			if(is_rotting)
				to_chat(H, SPAN_DANGER("The rotting mask burns your hand!"))
			else
				to_chat(H, SPAN_WARNING("The mask burns your hand!"))
			H.apply_damage(5, BURN)
		return
	if(ishuman(user))
		try_attach(user)

/obj/item/clothing/mask/scp035/proc/on_equipped(mob/living/carbon/human/user)
	if(user.stat == DEAD) user.revive()
	if(user.stat == UNCONSCIOUS) user.set_stat(CONSCIOUS)
	ADD_TRAIT(user, TRAIT_ADVANCED_TOOL_USER, "scp035")
	user.SCP = new /datum/scp(user, "possessed figure", SCP_KETER, "035", SCP_PLAYABLE)
	add_verb(user, /obj/item/clothing/mask/scp035/verb/Telepathy)
	add_verb(user, /obj/item/clothing/mask/scp035/verb/SwitchMask)
	add_verb(user, /obj/item/clothing/mask/scp035/verb/SecreteGoo)
	add_verb(user, /obj/item/clothing/mask/scp035/verb/SelfHeal)

	init_skills(user)

	is_recovering = FALSE
	decay = 0
	user.update_inv_wear_mask()

	to_chat(user, SPAN_DANGER("<font size='5'>An alien presence coils around your thoughts. A silken voice promises eternity, but your body already begins to rebel. You are now the vessel of SCP-035. Spread its influence. Find new flesh before this one decays.</font>"))

/obj/item/clothing/mask/scp035/proc/init_skills(mob/living/carbon/human/user)
	var/datum/skillset/skillset = user?.skillset
	if(!skillset)
		return
	skillset.skill_list = list()
	for(var/decl/hierarchy/skill/skill_decl in GLOB.skills)
		skillset.skill_list[skill_decl.type] = SKILL_UNTRAINED
	skillset.skill_list[SKILL_COMBAT] = SKILL_MASTER
	skillset.skill_list[SKILL_WEAPONS] = SKILL_MASTER
	skillset.skill_list[SKILL_FORENSICS] = SKILL_TRAINED
	skillset.skill_list[SKILL_HAULING] = SKILL_TRAINED
	skillset.on_levels_change()

/obj/item/clothing/mask/scp035/equipped(mob/user)
	. = ..()
	if(ishuman(user))
		on_equipped(user)

/obj/item/clothing/mask/scp035/proc/on_host_death(mob/living/carbon/human/H)
	if(H.SCP) qdel(H.SCP)
	REMOVE_TRAIT(H, TRAIT_ADVANCED_TOOL_USER, "scp035")
	H.death()
	H.drop_from_inventory(src)
	loc = get_turf(H)
	new /obj/item/remains/scp035(get_turf(H))
	is_rotting = TRUE
	is_recovering = TRUE
	update_mask_icon()
	spawn(600)
		if(src) finish_recovery()
	qdel(H)

/obj/item/clothing/mask/scp035/proc/finish_recovery()
	is_rotting = FALSE
	is_recovering = FALSE
	update_mask_icon()

/obj/item/clothing/mask/scp035/proc/add_decay(amount)
	var/old_decay = decay
	decay = min(100, decay + amount)
	if(decay != old_decay)
		to_chat(loc, SPAN_WARNING("Body decay: [round(decay)]%"))
	if(decay >= 50 && !is_rotting)
		is_rotting = TRUE
		update_mask_icon()
		to_chat(loc, SPAN_DANGER("Your flesh begins to rot visibly!"))
	if(decay >= 100)
		to_chat(loc, SPAN_DANGER("Your body crumbles away!"))

// ==================================================================
// Verbs
// ==================================================================

/obj/item/clothing/mask/scp035/verb/Telepathy()
	set name = "Telepathic Whisper"
	set category = "SCP-035"
	set src in usr
	if(!ishuman(usr)) return
	var/mob/living/carbon/human/H = usr
	if(H.wear_mask != src || world.time < telepathy_cooldown) return
	var/list/targets = list()
	for(var/mob/living/carbon/human/T in view(7, H))
		if(T != H && T.stat != DEAD) targets += T
	if(!targets.len) return
	var/mob/living/carbon/human/target = input(H, "Choose a target:") as null|anything in targets
	if(!target) return
	var/msg = sanitize(input(H, "Message:") as text|null)
	if(!msg) return
	to_chat(target, SPAN_NOTICE("<i>You hear a corrupting whisper: '[msg]'</i>"))
	to_chat(H, SPAN_NOTICE("<i>You project to [target.real_name]: '[msg]'</i>"))
	telepathy_cooldown = world.time + 10 SECONDS

/obj/item/clothing/mask/scp035/verb/SwitchMask()
	set name = "Switch Expression"
	set category = "SCP-035"
	set src in usr
	mask_type = (mask_type == "comedy") ? "tragedy" : "comedy"
	update_mask_icon()

/obj/item/clothing/mask/scp035/verb/SecreteGoo()
	set name = "Secrete Goo"
	set category = "SCP-035"
	set src in usr
	if(!ishuman(usr)) return
	var/mob/living/carbon/human/H = usr

	if(world.time < goo_cooldown)
		to_chat(H, SPAN_WARNING("Secrete Goo is on cooldown! [round((goo_cooldown - world.time) / 10)] seconds remaining."))
		return

	var/turf/T = get_step(usr, usr.dir)
	if(!T) T = get_turf(usr)
	if(!T || T.density)
		to_chat(H, SPAN_WARNING("There's no valid place to secrete goo!"))
		return
	new /obj/effect/decal/cleanable/scp035_goo(T)
	goo_cooldown = world.time + 30 SECONDS
	to_chat(H, SPAN_NOTICE("You secrete a puddle of black liquid."))
	add_decay(5)

/obj/item/clothing/mask/scp035/verb/SelfHeal()
	set name = "Self Heal"
	set category = "SCP-035"
	set src in usr
	if(!ishuman(usr)) return
	var/mob/living/carbon/human/H = usr

	if(world.time < heal_cooldown)
		to_chat(H, SPAN_WARNING("Self Heal is on cooldown! [round((heal_cooldown - world.time) / 10)] seconds remaining."))
		return

	H.heal_overall_damage(30, 30)
	H.adjustOxyLoss(-30)
	H.adjustToxLoss(-30)
	H.adjustCloneLoss(-30)

	for(var/obj/item/organ/external/E in H.organs)
		if(E.status & ORGAN_BROKEN)
			E.status &= ~ORGAN_BROKEN
		if(E.status & ORGAN_BLEEDING)
			E.status &= ~ORGAN_BLEEDING
		if(E.status & ORGAN_ARTERY_CUT)
			E.status &= ~ORGAN_ARTERY_CUT
		if(E.status & ORGAN_TENDON_CUT)
			E.status &= ~ORGAN_TENDON_CUT
		if(E.dislocated > 0)
			E.dislocated = 0
		E.heal_damage(30, 30)

	for(var/obj/item/organ/internal/I in H.internal_organs)
		I.damage = max(0, I.damage - 15)
		if(I.status & ORGAN_DEAD)
			I.status &= ~ORGAN_DEAD

	to_chat(H, SPAN_NOTICE("You feel decay receding as your wounds close and bones mend!"))
	heal_cooldown = world.time + 90 SECONDS
	add_decay(5)

// ==================================================================
// Process
// ==================================================================

/obj/item/clothing/mask/scp035/Process()
	if(is_recovering) return
	if(istype(loc, /obj/item/scp035_box)) return

	if(SCP)
		SCP.meme_comp.check_viewers()
		SCP.meme_comp.activate_memetic_effects()

	var/is_free = !ishuman(loc)

	if(is_free && !is_rotting)
		for(var/mob/living/carbon/human/H in view(1, src))
			if((H.stat == DEAD || H.stat == UNCONSCIOUS) && !ishostof035(H) && !H.SCP)
				try_attach(H)
				break

		if(world.time > last_goo + 3 MINUTES)
			last_goo = world.time
			var/list/turfs = list()
			for(var/turf/T in view(1, src))
				if(T == get_turf(src) || T.density || !T.Enter(null)) continue
				var/has_goo = FALSE
				for(var/obj/effect/decal/cleanable/scp035_goo/G in T)
					has_goo = TRUE
					break
				if(!has_goo) turfs += T
			if(turfs.len)
				new /obj/effect/decal/cleanable/scp035_goo(pick(turfs))

	if(ishuman(loc))
		var/mob/living/carbon/human/H = loc
		if(H.stat == DEAD)
			on_host_death(H)
			return
		H.stunned = 0
		H.weakened = 0
		H.paralysis = 0
		if(H.stat == UNCONSCIOUS)
			H.set_stat(CONSCIOUS)
			REMOVE_TRAIT(H, TRAIT_CRITICAL_CONDITION, STAT_TRAIT)
			REMOVE_TRAIT(H, TRAIT_HANDS_BLOCKED, STAT_TRAIT)
		if(world.time > decay_timer)
			add_decay(5)
			decay_timer = world.time + 2 MINUTES
		if(decay >= 100)
			on_host_death(H)
