#define MAX_BLEEDING 10
#define BASE_BLOODLOOS_TIME 5 SECONDS

/obj/item/organ/internal/heart
	name = "heart"
	icon_state = "heart-on"
	organ_tag = "heart"
	parent_organ = BP_CHEST
	dead_icon = "heart-off"
	var/pulse = PULSE_NORM
	var/heartbeat = 0
	var/beat_sound = 'sounds/effects/singlebeat.ogg'
	/// Cooldown for blood processing - tied to heart rate (BPM)
	var/tmp/next_blood_process = 0
	var/tmp/next_blood_squirt = 0
	damage_reduction = 0.7
	relative_size = 5
	max_damage = 45
	var/open
	var/list/external_pump

/obj/item/organ/internal/heart/open
	open = 1

/obj/item/organ/internal/heart/die()
	if(dead_icon)
		icon_state = dead_icon
	..()

/obj/item/organ/internal/heart/robotize()
	. = ..()
	icon_state = "heart-prosthetic"

/obj/item/organ/internal/heart/Process()
	if(owner)
		handle_pulse()
		if(pulse)
			handle_heartbeat()
			if(pulse == PULSE_2FAST && prob(1))
				take_internal_damage(0.5)
			if(pulse == PULSE_THREADY && prob(5))
				take_internal_damage(0.5)
		// Process blood only when heart actually beats (not every tick)
		// Heart rate determines bleeding speed - faster pulse = more frequent blood loss
		if(pulse != PULSE_NONE || BP_IS_ROBOTIC(src))
			if(world.time >= next_blood_process)
				handle_blood()
	..()

/obj/item/organ/internal/heart/proc/handle_pulse()
	if(BP_IS_ROBOTIC(src))
		pulse = PULSE_NONE	//that's it, you're dead (or your metal heart is), nothing can influence your pulse
		return

	// pulse mod starts out as just the chemical effect amount
	var/pulse_mod = owner.chem_effects[CE_PULSE]
	var/is_stable = owner.chem_effects[CE_STABLE]

	// If you have enough heart chemicals to be over 2, you're likely to take extra damage.
	if(pulse_mod > 2 && !is_stable)
		var/damage_chance = (pulse_mod - 2) ** 2
		if(prob(damage_chance))
			take_internal_damage(0.5)

	// Now pulse mod is impacted by shock stage and other things too
	if(owner.shock_stage > 30)
		pulse_mod++
	if(owner.shock_stage > 80)
		pulse_mod++

	var/oxy = owner.get_blood_oxygenation()
	if(oxy < BLOOD_VOLUME_OKAY) //brain wants us to get MOAR OXY
		pulse_mod++
	if(oxy < BLOOD_VOLUME_BAD) //MOAR
		pulse_mod++

	if(owner.status_flags & FAKEDEATH || owner.chem_effects[CE_NOPULSE])
		pulse = Clamp(PULSE_NONE + pulse_mod, PULSE_NONE, PULSE_2FAST) //pretend that we're dead. unlike actual death, can be inflienced by meds
		return

	//If heart is stopped, it isn't going to restart itself randomly.
	if(pulse == PULSE_NONE)
		return
	else //and if it's beating, let's see if it should
		var/should_stop = prob(80) && owner.get_blood_circulation() < BLOOD_VOLUME_SURVIVE //cardiovascular shock, not enough liquid to pump
		should_stop = should_stop || prob(max(0, owner.getBrainLoss() - owner.maxHealth * 0.75)) //brain failing to work heart properly
		should_stop = should_stop || (prob(5) && pulse == PULSE_THREADY) //erratic heart patterns, usually caused by oxyloss
		if(should_stop) // The heart has stopped due to going into traumatic or cardiovascular shock.
			to_chat(owner, SPAN_DANGER("Your heart has stopped!"))
			pulse = PULSE_NONE
			return

	// Pulse normally shouldn't go above PULSE_2FAST, unless extreme amounts of bad stuff in blood
	if (pulse_mod < 6)
		pulse = Clamp(PULSE_NORM + pulse_mod, PULSE_SLOW, PULSE_2FAST)
	else
		pulse = Clamp(PULSE_NORM + pulse_mod, PULSE_SLOW, PULSE_THREADY)

	// If fibrillation, then it can be PULSE_THREADY
	var/fibrillation = oxy <= BLOOD_VOLUME_SURVIVE || (prob(30) && owner.shock_stage > 120)
	if(pulse && fibrillation)	//I SAID MOAR OXYGEN
		pulse = PULSE_THREADY

	// Stablising chemicals pull the heartbeat towards the center
	if(pulse != PULSE_NORM && is_stable)
		if(pulse > PULSE_NORM)
			pulse--
		else
			pulse++

	// So does SCP-3349
	if(pulse != PULSE_NORM && ((SCP ? SCP.designation : "") == "3349-1"))
		if(pulse > PULSE_NORM)
			pulse--
		else
			pulse++

/obj/item/organ/internal/heart/proc/handle_heartbeat()
	if(pulse >= PULSE_2FAST || owner.shock_stage >= 10 || HAS_TRAIT(owner, TRAIT_HEAR_HEARTBEAT) || is_below_sound_pressure(get_turf(owner)))
		//PULSE_THREADY - maximum value for pulse, currently it 5.
		//High pulse value corresponds to a fast rate of heartbeat.
		//Divided by 2, otherwise it is too slow.
		var/rate = (PULSE_THREADY - pulse)/2
		if(owner.chem_effects[CE_PULSE] > 2)
			heartbeat++

		if(heartbeat >= (((SCP ? SCP.designation : "") == "3349-1") ? (rate * 2) : rate))	// scp3349 heartbeat is long so we play it half as often to prevent overlap
			heartbeat = 0
			sound_to(owner, sound((((SCP ? SCP.designation : "") == "3349-1") ? 'sounds/effects/heartbeatpurr.ogg' : beat_sound),0,0,0,50))
		else
			heartbeat++

/obj/item/organ/internal/heart/proc/handle_blood()

	if(!owner)
		return

	//Dead or cryosleep people do not pump the blood.
	if(!owner || owner.InStasis() || owner.stat == DEAD || owner.bodytemperature < 170)
		return

	if(pulse != PULSE_NONE || BP_IS_ROBOTIC(src))
		//Bleeding out
		var/blood_max = 0
		var/list/do_spray = list()

		for(var/obj/item/organ/external/temp in owner.organs)
			blood_max += handle_bleeding_organs(temp, do_spray)

		switch(pulse)
			if(PULSE_SLOW)
				blood_max *= 0.8
			if(PULSE_FAST)
				blood_max *= 1.25
			if(PULSE_2FAST, PULSE_THREADY)
				blood_max *= 1.4

		if(CE_STABLE in owner.chem_effects) // inaprovaline
			blood_max *= 0.6
		blood_max = min(MAX_BLEEDING, blood_max)

		handle_bloodloss(blood_max, do_spray)
	if(BP_IS_ROBOTIC(src))
		next_blood_process = world.time + 10
	else
		next_blood_process = world.time + max(4, 12 - (pulse * 2)) // Deciseconds (0.4s - 1.0s)

/obj/item/organ/internal/heart/proc/handle_bleeding_organs(obj/item/organ/external/ex_organ, list/arteries_spray)
	var/organ_bleeding = 0
	if(BP_IS_ROBOTIC(ex_organ))
		return

	var/open_wound
	if(ex_organ.status & ORGAN_BLEEDING)

		for(var/datum/wound/W in ex_organ.wounds)

			if(!open_wound && (W.damage_type == CUT || W.damage_type == PIERCE) && W.damage && !W.is_treated())
				open_wound = TRUE

			if(W.bleeding())
				if(ex_organ.applied_pressure)
					if(ishuman(ex_organ.applied_pressure))
						var/mob/living/carbon/human/H = ex_organ.applied_pressure
						H.bloody_hands(src, 0)
					var/min_eff_damage = max(0, W.damage - 10) / 6
					organ_bleeding += max(min_eff_damage, W.damage - 30) / 60
				else
					organ_bleeding += W.damage / 60

	if(ex_organ.status & ORGAN_ARTERY_CUT)
		var/base_bleed = 3.0 * ex_organ.arterial_bleed_severity
		if(ex_organ.applied_pressure)
			base_bleed *= 0.3
		else if(!open_wound)
			base_bleed *= 0.6
		var/bleed_amount = round(base_bleed, 0.1)
		if(bleed_amount >= 0.5)
			if(open_wound)
				arteries_spray += "[ex_organ.name]"
		organ_bleeding += bleed_amount
	return organ_bleeding

/obj/item/organ/internal/heart/proc/handle_bloodloss(blood_loss, list/arteries_spray)
	if(!blood_loss)
		return
	var/turf/sprayloc = get_turf(owner)
	if(arteries_spray.len && next_blood_squirt < world.time)
		var/spray_organ = pick(arteries_spray)
		owner.visible_message(
			SPAN_DANGER("Blood sprays out from \the [owner]'s [spray_organ]!"),
			FONT_HUGE(SPAN_DANGER("Blood sprays out from your [spray_organ]!"))
		)
		if(prob(60))
			owner.Stun(1)
			owner.set_eye_blur_if_lower(3 SECONDS)
		if(blood_loss > 0)
			blood_loss -= owner.blood_squirt(blood_loss*2, sprayloc)
		next_blood_squirt = world.time + BASE_BLOODLOOS_TIME

	if(blood_loss > 0)
		blood_loss -= owner.drip(ceil(blood_loss/3), sprayloc)
	owner.drip(blood_loss, get_turf(owner))

/obj/item/organ/internal/heart/proc/is_working()
	if(!is_usable())
		return FALSE

	return pulse > PULSE_NONE || BP_IS_ROBOTIC(src) || (owner.status_flags & FAKEDEATH)

/obj/item/organ/internal/heart/listen()
	if(BP_IS_ROBOTIC(src) && is_working())
		if(is_bruised())
			return "sputtering pump"
		else
			return "steady whirr of the pump"

	if(!pulse || (owner.status_flags & FAKEDEATH))
		return "no pulse"

	. = ""

	if(is_bruised())
		if(pulse == PULSE_NORM)
			. += "irregular "
		else
			. += "irregular, "

	switch(pulse)
		if(PULSE_SLOW)
			. += "slow "
		if(PULSE_FAST)
			. += "fast "
		if(PULSE_2FAST)
			. += "very fast "
		if(PULSE_THREADY)
			. += "extremely fast and faint "

	if(SCP?.designation == "3349-1")
		. += "cat purr"
	else
		. += "pulse"

/obj/item/organ/internal/heart/get_mechanical_assisted_descriptor()
	return "pacemaker-assisted [name]"
