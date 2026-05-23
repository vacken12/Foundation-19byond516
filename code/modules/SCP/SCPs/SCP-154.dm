// ==================== PROJECTILE ====================
/obj/item/projectile/bone_spear
	name = "bone spear"
	desc = "A razor-sharp bone shard flying at incredible speed."
	icon = 'icons/SCP/scp-154.dmi'
	icon_state = "154bone_spear"
	damage = 100
	damage_type = BRUTE
	armor_penetration = 50
	speed = 0.1

// ==================== BOW ====================
/obj/item/gun/projectile/scp154_bow
	name = "phantom bow"
	desc = "A large, blurry, incorporeal bow. There is no bowstring, but the gesture of drawing it produces the same effect."
	icon = 'icons/SCP/scp-154.dmi'
	icon_state = "154bow"
	item_state = "154bow"
	w_class = 5
	slot_flags = 0
	var/obj/item/clothing/gloves/scp154/parent_bracelets
	var/bow_drawn = FALSE

/obj/item/gun/projectile/scp154_bow/Initialize()
	. = ..()
	if(istype(loc, /obj/item/clothing/gloves/scp154))
		parent_bracelets = loc
	update_icon()

/obj/item/gun/projectile/scp154_bow/Destroy()
	if(parent_bracelets)
		parent_bracelets.active_bow = null
		parent_bracelets = null
	return ..()

/obj/item/gun/projectile/scp154_bow/update_icon()
	if(bow_drawn)
		icon_state = "154bow_stratched"
		item_state = "154bow"
	else
		icon_state = "154bow"
		item_state = "154bow"
	var/mob/M = loc
	if(istype(M))
		M.update_inv_l_hand()
		M.update_inv_r_hand()

/obj/item/gun/projectile/scp154_bow/attack_self(mob/user)
	if(!ishuman(user) || !parent_bracelets)
		return

	var/mob/living/carbon/human/H = user
	if(H.gloves != parent_bracelets)
		to_chat(user, SPAN_WARNING("The bracelets are no longer on you! The bow vanishes."))
		qdel(src)
		return

	if(bow_drawn)
		bow_drawn = FALSE
		update_icon()
		fire_bone_spear(user)
		return

	bow_drawn = TRUE
	user.visible_message(
		SPAN_WARNING("[user] raises the phantom bow and draws the invisible bowstring!"),
		SPAN_NOTICE("You raise the phantom bow and draw the invisible bowstring. The bones in your arm begin to vibrate from the tension."))
	update_icon()

/obj/item/gun/projectile/scp154_bow/afterattack(atom/target, mob/living/user, flag, params)
	if(!ishuman(user) || !parent_bracelets)
		return

	var/mob/living/carbon/human/H = user
	if(H.gloves != parent_bracelets)
		to_chat(user, SPAN_WARNING("The bracelets are no longer on you! The bow vanishes."))
		qdel(src)
		return

	if(get_dist(user, target) <= 1)
		return

	if(!bow_drawn)
		to_chat(user, SPAN_WARNING("Draw the bowstring first."))
		return

	bow_drawn = FALSE
	update_icon()
	fire_bone_spear(user, target)

/obj/item/gun/projectile/scp154_bow/proc/fire_bone_spear(mob/living/carbon/human/user, atom/target = null)
	var/obj/item/organ/external/left_hand = user.get_organ(BP_L_ARM)
	var/obj/item/organ/external/right_hand = user.get_organ(BP_R_ARM)
	var/obj/item/organ/external/active_hand

	if(user.hand)
		active_hand = right_hand
	else
		active_hand = left_hand

	var/left_broken = left_hand && (left_hand.status & ORGAN_BROKEN)
	var/right_broken = right_hand && (right_hand.status & ORGAN_BROKEN)

	if(!left_hand && !right_hand)
		to_chat(user, SPAN_WARNING("You have no arms to fire with!"))
		return

	if(left_broken && right_broken)
		to_chat(user, SPAN_WARNING("Both of your arms are broken! You cannot fire until you are healed."))
		bow_drawn = TRUE
		update_icon()
		return

	if(active_hand && (active_hand.status & ORGAN_BROKEN))
		if(user.hand)
			if(left_hand && !(left_hand.status & ORGAN_BROKEN))
				active_hand = left_hand
				user.visible_message(SPAN_WARNING("[user] switches the bow to their left hand."))
			else
				to_chat(user, SPAN_WARNING("Your right arm is broken and your left arm is also unavailable!"))
				bow_drawn = TRUE
				update_icon()
				return
		else
			if(right_hand && !(right_hand.status & ORGAN_BROKEN))
				active_hand = right_hand
				user.visible_message(SPAN_WARNING("[user] switches the bow to their right hand."))
			else
				to_chat(user, SPAN_WARNING("Your left arm is broken and your right arm is also unavailable!"))
				bow_drawn = TRUE
				update_icon()
				return

	to_chat(user, SPAN_DANGER("You release the phantom bowstring and the bones of your arm burst out with a sickening crunch, forming a deadly projectile!"))
	user.emote("scream")

	active_hand.fracture()
	active_hand.brute_dam += 50

	var/obj/item/projectile/bone_spear/arrow = new(get_turf(user))
	arrow.firer = user
	arrow.original = target ? target : get_step(get_turf(user), user.dir)
	arrow.launch(arrow.original, user)

	parent_bracelets.start_healing(user)

/obj/item/gun/projectile/scp154_bow/dropped(mob/user)
	if(parent_bracelets)
		to_chat(user, SPAN_NOTICE("The phantom bow vanishes, retreating back into the bracelets."))
	. = ..()
	qdel(src)

/obj/item/gun/projectile/scp154_bow/equipped(mob/user, slot)
	if(slot == slot_l_hand || slot == slot_r_hand)
		return ..()
	if(parent_bracelets)
		to_chat(user, SPAN_WARNING("The phantom bow cannot exist outside of your hands and vanishes."))
	qdel(src)

// ==================== BRACELETS ====================
/obj/item/clothing/gloves/scp154
	name = "pair of bronze bracelets"
	desc = "A pair of simple bronze bracelets. They appear harmless, but a strange warmth emanates from them."
	icon = 'icons/SCP/scp-154.dmi'
	icon_state = "154bracelets"
	item_state = "154bracelets"
	sprite_sheets = list(
		SPECIES_HUMAN = 'icons/mob/onmob/onmob_hands.dmi'
	)
	var/heal_timer_id
	var/mob/living/carbon/human/current_wearer
	var/active_bow = null

/obj/item/clothing/gloves/scp154/Initialize()
	. = ..()
	SCP = new /datum/scp(
		src,
		"pair of bronze bracelets",
		SCP_EUCLID,
		"154"
	)

/obj/item/clothing/gloves/scp154/equipped(mob/user, slot)
	. = ..()
	if(slot == slot_gloves)
		current_wearer = user
		add_verb(user, /obj/item/clothing/gloves/scp154/verb/summon_bow)
		to_chat(user, SPAN_NOTICE("The bracelets tighten around your wrists. You feel power flowing through your arms."))
	else
		remove_verb(user, /obj/item/clothing/gloves/scp154/verb/summon_bow)
		stop_healing()
		current_wearer = null

/obj/item/clothing/gloves/scp154/dropped(mob/user)
	. = ..()
	remove_verb(user, /obj/item/clothing/gloves/scp154/verb/summon_bow)
	if(current_wearer)
		stop_healing()
		current_wearer = null

/obj/item/clothing/gloves/scp154/proc/stop_healing()
	if(heal_timer_id)
		deltimer(heal_timer_id)
		heal_timer_id = null
	if(current_wearer)
		to_chat(current_wearer, SPAN_WARNING("The connection to the bracelets is severed, and the healing energy dissipates."))

/obj/item/clothing/gloves/scp154/verb/summon_bow()
	set name = "Summon SCP-154 Bow"
	set desc = "Summon or dismiss the phantom bow."
	set category = "Abilities"
	set src in usr

	if(!ishuman(usr))
		return

	var/mob/living/carbon/human/H = usr
	if(H.gloves != src)
		to_chat(H, SPAN_WARNING("You must wear the bracelets on your hands."))
		remove_verb(H, /obj/item/clothing/gloves/scp154/verb/summon_bow)
		return

	if(active_bow)
		QDEL_NULL(active_bow)
		to_chat(H, SPAN_NOTICE("The phantom bow vanishes, retreating back into the bracelets."))
		return

	active_bow = new /obj/item/gun/projectile/scp154_bow(src)
	H.put_in_active_hand(active_bow)
	to_chat(H, SPAN_NOTICE("The bracelets begin to glow! A phantom bow, woven from pure energy, materializes in your hand."))

/obj/item/clothing/gloves/scp154/proc/start_healing(mob/living/carbon/human/user)
	if(heal_timer_id)
		deltimer(heal_timer_id)
	to_chat(user, SPAN_NOTICE("The bracelets begin to vibrate, channeling energy to restore your arms. This will take about 20 seconds."))
	heal_timer_id = addtimer(CALLBACK(src, PROC_REF(heal_bones)), 20 SECONDS, TIMER_STOPPABLE)

/obj/item/clothing/gloves/scp154/proc/heal_bones()
	heal_timer_id = null
	if(!current_wearer)
		return
	var/mob/living/carbon/human/H = current_wearer
	if(H.gloves != src)
		to_chat(H, SPAN_WARNING("Healing interrupted: the bracelets are no longer on you."))
		return

	to_chat(H, SPAN_NOTICE("The energy of the bracelets fills your arms. The bones snap back into place."))

	var/list/arms = list(H.get_organ(BP_L_ARM), H.get_organ(BP_R_ARM))
	for(var/obj/item/organ/external/arm in arms)
		if(arm)
			arm.status &= ~ORGAN_BROKEN

	H.regenerate_icons()
