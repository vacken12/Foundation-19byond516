// ==================================================================
// SCP-035 - Possessive Mask (final version)
// ==================================================================

/obj/effect/decal/cleanable/scp035_goo
	name = "black liquid"
	desc = "A thick, black, corrosive substance."
	icon = 'icons/effects/effects.dmi'
	icon_state = "greenglow"
	color = "#1a1a1a"
	alpha = 180
	anchored = TRUE

/obj/effect/decal/cleanable/scp035_goo/Crossed(mob/living/L)
	if(istype(L) && L.stat != DEAD && !ishostof035(L))
		L.apply_damage(9, BURN)
		to_chat(L, SPAN_DANGER("The black liquid burns your skin!"))

/proc/ishostof035(mob/living/L)
	if(!ishuman(L))
		return FALSE
	var/mob/living/carbon/human/H = L
	return istype(H.wear_mask, /obj/item/clothing/mask/scp035)

/obj/item/remains/scp035
	name = "corroded remains"
	desc = "They look like human remains, blackened and corroded beyond recognition."
	icon = 'icons/effects/blood.dmi'
	icon_state = "remains"
	color = "#1a1a1a"

/obj/item/remains/scp035/attack_hand(mob/user)
	to_chat(user, SPAN_WARNING("The remains crumble into ash at your touch."))
	new /obj/effect/decal/cleanable/ash(get_turf(src))
	qdel(src)

// ==================================================================
// Door Corrosion
// ==================================================================

/obj/effect/scp035_door_corrosion
	name = "black corrosion"
	icon = 'icons/effects/effects.dmi'
	icon_state = "greenglow"
	color = "#1a1a1a"
	alpha = 200
	anchored = TRUE
	var/obj/machinery/door/target_door
	var/melt_time = 1 MINUTES
	var/melt_timer

/obj/effect/scp035_door_corrosion/Initialize(mapload, obj/machinery/door/door)
	. = ..()
	if(door)
		target_door = door
		melt_timer = addtimer(CALLBACK(src, PROC_REF(melt_door)), melt_time, TIMER_STOPPABLE)

/obj/effect/scp035_door_corrosion/Destroy()
	if(melt_timer) deltimer(melt_timer)
	target_door = null
	return ..()

/obj/effect/scp035_door_corrosion/proc/melt_door()
	if(target_door && !QDELETED(target_door))
		visible_message(SPAN_DANGER("[target_door] collapses!"))
		if(istype(target_door, /obj/machinery/door/blast))
			var/obj/machinery/door/blast/B = target_door
			B.force_open()
		else
			target_door.set_broken(TRUE)
			target_door.open(TRUE)
	qdel(src)

// ==================================================================
// Transport Container
// ==================================================================

/obj/item/scp035_box
	name = "SCP-035 Containment Box"
	desc = "A lead-lined containment box for SCP-035."
	icon = 'icons/SCP/scp-035.dmi'
	icon_state = "box"
	item_state = "box"
	w_class = ITEM_SIZE_NORMAL
	var/obj/item/clothing/mask/scp035/contained_mask = null

/obj/item/scp035_box/Initialize()
	. = ..()
	update_icon()

/obj/item/scp035_box/update_icon()
	if(contained_mask)
		icon_state = "in_box"
	else
		icon_state = "box"

/obj/item/scp035_box/attack_self(mob/user)
	if(contained_mask)
		var/obj/item/clothing/mask/scp035/M = contained_mask
		M.is_rotting = FALSE
		M.is_recovering = FALSE
		M.finish_recovery()
		M.update_mask_icon()
		M.forceMove(get_turf(user))
		contained_mask = null
		to_chat(user, SPAN_WARNING("You open [src] and pull out [M]!"))
		playsound(src, 'sounds/machines/bolts_up.ogg', 50, 1)
		update_icon()
	else
		to_chat(user, SPAN_NOTICE("[src] is empty. Click it on a mask to contain it."))

/obj/item/scp035_box/afterattack(atom/target, mob/user, proximity_flag)
	if(proximity_flag && istype(target, /obj/item/clothing/mask/scp035) && !contained_mask)
		var/obj/item/clothing/mask/scp035/M = target
		if(ishuman(M.loc))
			to_chat(user, SPAN_WARNING("You cannot seal the mask while it is being worn!"))
			return
		M.forceMove(src)
		contained_mask = M
		M.breach_timer = world.time + 30 MINUTES
		M.teleport_timer = 0
		visible_message(SPAN_NOTICE("[user] seals [M] into [src]."))
		playsound(src, 'sounds/machines/bolts_down.ogg', 50, 1)
		update_icon()
		return
	..()

/obj/item/scp035_box/Destroy()
	if(contained_mask)
		contained_mask.forceMove(get_turf(src))
		contained_mask = null
	return ..()

/obj/item/scp035_box/prefilled/Initialize()
	. = ..()
	var/obj/item/clothing/mask/scp035/M = new(src)
	contained_mask = M
	M.breach_timer = world.time + 30 MINUTES
	update_icon()

// ==================================================================
// SCP-035 - Mask
// ==================================================================

/obj/item/clothing/mask/scp035
	name = "white mask"
	desc = "A white porcelain theatrical mask."
	icon = 'icons/SCP/scp-035.dmi'
	icon_state = "comedy_obj"
	item_state = "comedy_obj"
	body_parts_covered = FACE
	canremove = FALSE
	w_class = ITEM_SIZE_SMALL

	item_icons = list(slot_wear_mask_str = 'icons/SCP/scp-035.dmi')

	var/mask_type = "comedy"
	var/is_rotting = FALSE
	var/is_recovering = FALSE

	var/decay_level = 0
	var/max_decay = 100
	var/rot_threshold = 50
	var/decay_timer = 0

	var/telepathy_cooldown = 10 SECONDS
	var/telepathy_cooldown_track = 0
	var/goo_cooldown = 5 SECONDS
	var/goo_cooldown_track = 0
	var/door_cooldown = 30 SECONDS
	var/door_cooldown_track = 0
	var/heal_cooldown = 15 SECONDS
	var/heal_cooldown_track = 0

	var/strategy = "passive"
	var/corrosion_timer = 0
	var/breach_timer = 0
	var/teleport_timer = 0

/obj/item/clothing/mask/scp035/Initialize()
	. = ..()
	strategy = pick("passive";60, "aggressive";40)
	SCP = new /datum/scp(src, "white mask", SCP_KETER, "035", SCP_MEMETIC)
	SCP.memeticFlags = MVISUAL | MAUDIBLE
	SCP.memetic_proc = TYPE_PROC_REF(/obj/item/clothing/mask/scp035, memetic_effect)
	SCP.compInit()
	START_PROCESSING(SSobj, src)
	mask_type = pick("comedy", "tragedy")
	update_mask_icon()
	breach_timer = world.time + 30 MINUTES

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

/obj/item/clothing/mask/scp035/get_mob_overlay(mob/user_mob, slot)
	var/image/ret = ..()
	if(slot == slot_wear_mask_str)
		ret.icon_state = "[mask_type][is_rotting ? "_rot" : ""]"
	return ret

/obj/item/clothing/mask/scp035/proc/memetic_effect(mob/living/carbon/human/H)
	if(is_recovering) return
	if(!H || H.stat == UNCONSCIOUS || !H.can_see(src)) return
	if(H.stat == DEAD) return
	if(H.SCP) return
	if(ishostof035(H)) return
	if(istype(loc, /obj/item/scp035_box) || ishuman(loc)) return

	if(get_dist(H, src) <= 5)
		if(get_dist(H, src) > 1)
			step_to(H, src)
			to_chat(H, SPAN_WARNING("You feel drawn to \the [src]..."))
		else
			H.equip_to_slot_or_del(src, slot_wear_mask)
			visible_message(SPAN_DANGER("\The [src] latches onto [H]'s face!"))
			playsound(get_turf(H), 'sounds/effects/splat.ogg', 50, 1)
			on_equipped(H)

/obj/item/clothing/mask/scp035/attack_hand(mob/user)
	if(is_recovering)
		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			to_chat(H, SPAN_DANGER("The black liquid burns your hand!"))
			H.adjustFireLoss(5)
		return
	if(ishuman(user) && user.get_equipped_item(slot_wear_mask) == src)
		return
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.SCP) return
		if(H.wear_mask)
			H.drop_from_inventory(H.wear_mask)
		H.equip_to_slot_or_del(src, slot_wear_mask)
		visible_message(SPAN_DANGER("\The [src] latches onto [H]'s face!"))
		playsound(get_turf(H), 'sounds/effects/splat.ogg', 50, 1)
		on_equipped(H)
		return
	return

/obj/item/clothing/mask/scp035/proc/on_equipped(mob/living/carbon/human/user)
	if(user.stat == DEAD)
		user.revive()
		user.SCP = new /datum/scp(user, "possessed figure", SCP_KETER, "035", SCP_PLAYABLE)

	add_verb(user, /obj/item/clothing/mask/scp035/verb/Telepathy)
	add_verb(user, /obj/item/clothing/mask/scp035/verb/SwitchMask)
	add_verb(user, /obj/item/clothing/mask/scp035/verb/CorrodeDoor)
	add_verb(user, /obj/item/clothing/mask/scp035/verb/SecreteGoo)
	add_verb(user, /obj/item/clothing/mask/scp035/verb/SelfHeal)

	is_recovering = FALSE
	decay_level = 0

	user.update_inv_wear_mask()

	to_chat(user, SPAN_DANGER("<font size='5'>An alien presence coils around your thoughts. A silken voice promises eternity, but your body already begins to rebel. You are now the vessel of SCP-035. Spread its influence. Find new flesh before this one decays.</font>"))

/obj/item/clothing/mask/scp035/equipped(mob/user)
	. = ..()
	if(ishuman(user))
		on_equipped(user)

/obj/item/clothing/mask/scp035/proc/on_host_death(mob/living/carbon/human/H)
	H.death()
	canremove = TRUE
	H.drop_from_inventory(src)
	canremove = FALSE
	forceMove(get_turf(H))

	new /obj/item/remains/scp035(get_turf(H))

	is_rotting = TRUE
	is_recovering = TRUE
	update_mask_icon()
	addtimer(CALLBACK(src, PROC_REF(finish_recovery)), 1 MINUTES)

	qdel(H)

/obj/item/clothing/mask/scp035/proc/finish_recovery()
	is_rotting = FALSE
	is_recovering = FALSE
	update_mask_icon()

/obj/item/clothing/mask/scp035/proc/add_decay(amount)
	var/old_level = decay_level
	decay_level = min(max_decay, decay_level + amount)
	if(decay_level != old_level)
		to_chat(loc, SPAN_WARNING("The decay of your body deepens... ([round(decay_level)]%)"))

// ==================================================================
// Verbs
// ==================================================================

/obj/item/clothing/mask/scp035/verb/Telepathy()
	set name = "Telepathic Whisper"
	set category = "SCP-035"
	set src in usr

	if(!ishuman(usr)) return
	var/mob/living/carbon/human/H = usr
	if(H.wear_mask != src) return
	if(world.time < telepathy_cooldown_track) return

	var/list/targets = list()
	for(var/mob/living/carbon/human/T in view(7, H))
		if(T != H && T.stat != DEAD) targets += T
	if(!targets.len) return
	var/mob/living/carbon/human/target = input(H, "Choose a target:", "Telepathy") as null|anything in targets
	if(!target) return
	var/msg = input(H, "Message:", "Telepathy") as text|null
	if(!msg) return
	to_chat(target, SPAN_NOTICE("<i>You hear a corrupting whisper: '[msg]'</i>"))
	telepathy_cooldown_track = world.time + telepathy_cooldown

/obj/item/clothing/mask/scp035/verb/SwitchMask()
	set name = "Switch Expression"
	set category = "SCP-035"
	set src in usr

	mask_type = (mask_type == "comedy") ? "tragedy" : "comedy"
	update_mask_icon()

/obj/item/clothing/mask/scp035/verb/CorrodeDoor()
	set name = "Corrode Door"
	set category = "SCP-035"
	set src in usr

	if(!ishuman(usr)) return
	var/mob/living/carbon/human/H = usr
	if(H.wear_mask != src) return
	if(world.time < door_cooldown_track || H.stat == DEAD) return

	var/turf/front = get_step(H, H.dir)
	var/obj/machinery/door/target_door = locate() in front
	if(!target_door?.density) return
	visible_message(SPAN_DANGER("[H] smears black liquid onto [target_door]!"))
	new /obj/effect/scp035_door_corrosion(get_turf(target_door), target_door)
	door_cooldown_track = world.time + door_cooldown
	add_decay(5)

/obj/item/clothing/mask/scp035/verb/SecreteGoo()
	set name = "Secrete Goo"
	set category = "SCP-035"
	set src in usr

	if(!ishuman(usr)) return
	var/mob/living/carbon/human/H = usr
	if(H.wear_mask != src) return
	if(world.time < goo_cooldown_track || H.stat == DEAD) return
	new /obj/effect/decal/cleanable/scp035_goo(get_turf(H))
	visible_message(SPAN_DANGER("[H] secretes a puddle of black liquid!"))
	goo_cooldown_track = world.time + goo_cooldown
	add_decay(5)

/obj/item/clothing/mask/scp035/verb/SelfHeal()
	set name = "Self Heal"
	set category = "SCP-035"
	set src in usr

	if(!ishuman(usr)) return
	var/mob/living/carbon/human/H = usr
	if(H.wear_mask != src) return
	if(world.time < heal_cooldown_track) return

	H.heal_overall_damage(20, 20)
	H.adjustOxyLoss(-20)
	H.adjustToxLoss(-20)
	H.adjustCloneLoss(-20)
	H.radiation = max(H.radiation - 30, 0)
	H.AdjustStunned(-2)
	H.AdjustWeakened(-2)
	H.adjust_stamina(H.max_stamina)
	H.reagents.add_reagent(/datum/reagent/medicine/painkiller/tramadol, 5)

	for(var/obj/item/organ/internal/I in H.internal_organs)
		I.heal_damage(5)
	for(var/obj/item/organ/external/E in H.organs)
		if(prob(35)) E.status &= ~ORGAN_BROKEN
		if(prob(45)) E.status &= ~ORGAN_BLEEDING

	H.UpdateDamageIcon()
	visible_message(SPAN_DANGER("[H]'s wounds close as black liquid seeps from the mask!"))
	heal_cooldown_track = world.time + heal_cooldown
	add_decay(5)

// ==================================================================
// Process
// ==================================================================

/obj/item/clothing/mask/scp035/Process()
	if(is_recovering) return

	if(istype(loc, /obj/item/scp035_box))
		if(strategy == "aggressive" && world.time > breach_timer && prob(15))
			var/obj/item/scp035_box/box = loc
			forceMove(get_turf(box))
			box.contained_mask = null
			box.update_icon()
			visible_message(SPAN_DANGER("[src] bursts out of [box]!"))
			teleport_timer = world.time + 5 MINUTES
		return

	if(ishuman(loc))
		var/mob/living/carbon/human/H = loc
		if(H.stat == DEAD)
			on_host_death(H)
			return
		if(H.stunned) H.stunned = 0
		if(H.weakened) H.weakened = 0
		if(H.lying) H.lying = 0
		if(H.stat == UNCONSCIOUS) H.stat = CONSCIOUS

		if(world.time > decay_timer)
			add_decay(5)
			decay_timer = world.time + 1 MINUTES

		if(decay_level >= rot_threshold && !is_rotting)
			is_rotting = TRUE
			update_mask_icon()

		if(decay_level >= max_decay)
			to_chat(H, SPAN_DANGER("Your body crumbles away!"))
			on_host_death(H)
			return
	else
		if(strategy == "aggressive" && world.time > teleport_timer)
			teleport_timer = world.time + 5 MINUTES
			var/mob/living/carbon/human/target = null
			for(var/mob/living/carbon/human/T in view(20, src))
				if(!T.get_equipped_item(slot_wear_mask) && !T.SCP)
					target = T
					break
			if(target)
				var/turf/dest = get_step(target, pick(NORTH, SOUTH, EAST, WEST))
				if(dest && !dest.density)
					forceMove(dest)
					visible_message(SPAN_DANGER("[src] materializes near [target]!"))

		if(world.time > corrosion_timer)
			var/corrode_chance = (strategy == "aggressive") ? 40 : 10
			var/corrode_delay = (strategy == "aggressive") ? 5 SECONDS : 15 SECONDS
			corrosion_timer = world.time + corrode_delay
			if(prob(corrode_chance))
				var/turf/T = get_step(src, pick(NORTH, SOUTH, EAST, WEST))
				if(!T.density)
					new /obj/effect/decal/cleanable/scp035_goo(T)

		SCP.meme_comp.check_viewers()
		SCP.meme_comp.activate_memetic_effects()
