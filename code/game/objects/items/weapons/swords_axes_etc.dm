/* Weapons
 * Contains:
 *		Sword
 *		Classic Baton
 */

/*
 * Classic Baton
 */
/obj/item/melee/classic_baton
	name = "police baton"
	desc = "A wooden truncheon for beating criminal scum."
	icon = 'icons/obj/weapons/melee_physical.dmi'
	icon_state = "baton"
	item_state = "classic_baton"
	slot_flags = SLOT_BELT
	force = 10

	drop_sound = SFX_DROP_CROWBAR
	pickup_sound = SFX_PICKUP_CROWBAR

/obj/item/melee/classic_baton/attack(mob/M as mob, mob/living/user as mob)
	if (((MUTATION_CLUMSY in user.mutations) || (HAS_TRAIT(user, TRAIT_CLUMSY))) && prob(50))
		to_chat(user, SPAN_WARNING("You club yourself over the head."))
		user.Weaken(3 * force)
		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			H.apply_damage(2*force, BRUTE, BP_HEAD)
		else
			user.take_organ_damage(2*force, 0)
		return
	return ..()

//Telescopic baton
/obj/item/melee/telebaton
	name = "telescopic baton"
	desc = "A compact yet rebalanced personal defense weapon. Can be concealed when folded."
	icon = 'icons/obj/weapons/melee_physical.dmi'
	icon_state = "telebaton_0"
	item_state = "telebaton_0"
	slot_flags = SLOT_BELT
	w_class = ITEM_SIZE_SMALL
	force = 3
	attack_ignore_harm_check = 1
	var/agonyforce = 20 //Adding more pain if harming,less if not equal OR better at cqc AND atlethics(hauling)
	var/stunforce = 1 //applied if in HvH user is dangerous to target(either equal or better cqc+hauling or target's legs broken)
	var/on = 0
	var/integrity_hits = 16 //how many hits we can make before steel go "unusable"
	var/breaked = 0 //for delayed attack_self realisation

	drop_sound = SFX_DROP_CROWBAR
	pickup_sound = SFX_PICKUP_CROWBAR

/obj/item/melee/telebaton/examine(mob/user, distance)
	. = ..()
	switch(integrity_hits)
		if(10 to 16)
			to_chat(user, SPAN_GOOD("Baton's rod is looking normal"))
		if(7 to 9)
			to_chat(user, SPAN_WARNING("Baton's rod is looking damaged"))
		if(4 to 6)
			to_chat(user, SPAN_BAD("Baton's rod angle is looing unnormal"))
		if(1 to 3)
			to_chat(user, SPAN_DANGER("Baton's rod is going to collapse"))
		if(0)
			to_chat(user, SPAN_ALERT("Baton is beyond practical use"))

/obj/item/melee/telebaton/attack_self(mob/user as mob)
	if(integrity_hits == 0 & !breaked)
		user.visible_message(SPAN_NOTICE("\The Iron sound echoes around [user] as metallic rod falls from weapon."),\
		SPAN_NOTICE("Baton is loosing balance."),\
		"You hear an awful metallic sound.")
		on = FALSE
		force = 3//not so robust now
		attack_verb = list("hit", "punched")
		playsound(src.loc, 'sounds/weapons/wristblades_on.ogg', 70, 1)//metallic enough,but i thinked about metal pipe,ha-ha
		break_baton()
		return
	if(breaked)
		to_chat(user, "There nothing to do with it")
		return
	on = !on
	if(on)
		user.visible_message(SPAN_WARNING("With a flick of their wrist, [user] extends their telescopic baton."),\
		SPAN_WARNING("You extend the baton."),\
		"You hear an ominous click.")
		w_class = ITEM_SIZE_NORMAL
		force = 15//quite robust
		attack_verb = list("smacked", "struck", "slapped")
	else
		user.visible_message(SPAN_NOTICE("\The [user] collapses their telescopic baton."),\
		SPAN_NOTICE("You collapse the baton."),\
		"You hear a click.")
		w_class = ITEM_SIZE_SMALL
		force = 3//not so robust now
		attack_verb = list("hit", "punched")

	playsound(src.loc, 'sounds/weapons/empty.ogg', 50, 1)
	add_fingerprint(user)
	update_icon()
	update_held_icon()

/obj/item/melee/telebaton/on_update_icon()
	if(breaked)
		cut_overlays()
		return
	if(on)
		icon_state = "telebaton_1"
		item_state = "telebaton_1"
	else
		icon_state = "telebaton_0"
		item_state = "telebaton_0"
	if(length(blood_DNA))
		generate_blood_overlay(TRUE) // Force recheck.
		cut_overlays()
		add_overlay(blood_overlay)

/obj/item/melee/telebaton/attack(mob/target as mob, mob/living/user as mob)
	if(on)
		if (((MUTATION_CLUMSY in user.mutations) || (HAS_TRAIT(user, TRAIT_CLUMSY))) && prob(50))
			to_chat(user, SPAN_WARNING("You club yourself over the head."))
			user.Weaken(3 * force)
			if(ishuman(user))
				var/mob/living/carbon/human/H = user
				H.apply_damage(2*force, BRUTE, BP_HEAD)
			else
				user.take_organ_damage(2*force, 0)
			return
		if(..())
			//playsound(src.loc, "swing_hit", 50, 1, -1)
			return
	else
		return ..()

/obj/item/melee/telebaton/apply_hit_effect(mob/living/target, mob/living/user, hit_zone)
	if(isrobot(target))
		return ..()

	var/mob/living/carbon/human/H_target
	var/agony = agonyforce
	var/stun = stunforce
	var/obj/item/organ/external/affecting = null
	if(ishuman(target))
		H_target = target
		affecting = H_target.get_organ(hit_zone)
	var/abuser =  user ? "" : "by [user]"
	var/profficient_cqc = FALSE
	if((user.get_skill_difference(SKILL_COMBAT, target) >= 0) & (user.get_skill_difference(SKILL_HAULING, target) >= 0))
		profficient_cqc = TRUE
	else
		agony *= 0.5 //can not release potential

	//we can't really extract the actual hit zone from ..(), unfortunately. Just act like they attacked the area they intended to.
	if((user && user.a_intent != I_HURT) & !on)
		if(affecting)
			target.visible_message(SPAN_WARNING("[target] has been beated in the [affecting.name] with [src][abuser]. Luckily it was collapsed."))
		else
			target.visible_message(SPAN_WARNING("[target] has been beated with [src][abuser]. Luckily it was collapsed."))
	if((user && user.a_intent != I_HURT) & on)
		if(affecting)
			target.visible_message(SPAN_DANGER("[target] has been beated in the [affecting.name] with [src][abuser]"))
		else
			target.visible_message(SPAN_DANGER("[target] has been beated with [src][abuser]."))

	if(user && user.a_intent == I_HURT)
		agony *= 1.5 //MORE PAIN FOR THE FUN, no matter if user is looser
		. = ..()

	//stun effects
	var/hitting_legs
	var/legs_broken
	if(affecting && (affecting.organ_tag in (BP_LEGS_FEET)))
		hitting_legs = 1
		for(var/_limb in BP_LEGS_FEET)
			var/obj/item/organ/external/limb = H_target.get_organ(_limb)
			if(limb.status & ORGAN_BROKEN)
				legs_broken = 1 //Can not stand properly
	if(on & (hitting_legs == TRUE & legs_broken)) //target can not resist properly
		target.stun_effect_act(stun, agony, hit_zone, src)
		msg_admin_attack("[key_name(user)] dropped [key_name(target)] with the [src].")
		integrity_hits--

		if(ishuman(target))
			var/mob/living/carbon/human/H = target
			H.forcesay(GLOB.hit_appends)
		if(integrity_hits == 0)
			attack_self(user)
		return 1
	if(on & (hitting_legs == TRUE & profficient_cqc)) //just brute force
		target.stun_effect_act(stun, agony, hit_zone, src)
		msg_admin_attack("[key_name(user)] dropped [key_name(target)] with the [src].")
		integrity_hits--

		if(ishuman(target))
			var/mob/living/carbon/human/H = target
			H.forcesay(GLOB.hit_appends)
		if(integrity_hits == 0)
			attack_self(user)
		return 1
	if(on)
		target.stun_effect_act(agony, hit_zone, src) //just agony,PAIN
		integrity_hits--
	if(user && user.a_intent == I_HURT)
		if(.) //triggering harm-atack
			if(integrity_hits == 0 & !breaked)
				attack_self(user)
			return

	return 1

/obj/item/melee/telebaton/proc/break_baton()
	new /obj/item/stack/material/rods(loc.loc, 1)
	if(blood_DNA)
		var/obj/effect/decal/cleanable/blood/blood = new /obj/effect/decal/cleanable/blood(loc.loc)
		blood.blood_DNA += blood_DNA
	icon_state = "telebaton_breaked"
	item_state = "telebaton_breaked"
	breaked = 1
	update_icon()
