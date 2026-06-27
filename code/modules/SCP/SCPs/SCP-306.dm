// ============================================================================
// SCP-306 - Frog Transformation Virus
// ============================================================================

// ============================================================================
// DISEASE
// ============================================================================

/datum/disease/scp306
	name = "Anuran Degeneration"
	form = "Viral Transformation"
	max_stages = 3
	spread_text = "Physical contact, bodily fluids"
	spread_flags = DISEASE_SPREAD_BLOOD | DISEASE_SPREAD_CONTACT_SKIN | DISEASE_SPREAD_CONTACT_FLUIDS
	cure_text = "None known. Termination of infected recommended."
	cures = list()
	agent = "SCP-306 viral agent"
	viable_mobtypes = list(/mob/living/carbon/human)
	desc = "An anomalous virus that slowly transforms human tissue into that of a frog."
	severity = DISEASE_SEVERITY_BIOHAZARD
	permeability_mod = 1
	bypasses_immunity = TRUE
	var/transformation_progress = 0

/datum/disease/scp306/StageAct()
	. = ..()
	if(!.)
		return
	var/mob/living/carbon/human/H = affected_mob
	if(!istype(H))
		return
	// Don't affect SCPs
	if(H.SCP)
		return

	switch(stage)
		if(1)
			if(prob(40))
				to_chat(H, SPAN_WARNING("Your skin feels unusually dry and tight."))
			if(prob(30))
				H.adjustToxLoss(1)
				to_chat(H, SPAN_WARNING("Small green blotches appear on your skin."))
			if(prob(20))
				to_chat(H, SPAN_WARNING("Your fingers feel stiff and slightly webbed."))
			transformation_progress += 8

		if(2)
			if(prob(40))
				H.adjustBruteLoss(3)
				H.Weaken(3)
				to_chat(H, SPAN_DANGER("<b>Your bones crack and reform as your body shrinks!</b>"))
				H.visible_message(SPAN_DANGER("[H]'s body contorts, shrinking and warping!"))
			if(prob(30))
				H.adjustToxLoss(2)
				to_chat(H, SPAN_DANGER("Your tongue extends and becomes sticky. Your eyes bulge."))
				H.visible_message(SPAN_WARNING("[H]'s eyes appear to bulge slightly."))
			if(prob(20))
				H.Weaken(4)
				H.Stun(2)
				to_chat(H, SPAN_DANGER("A horrible croaking sound escapes your throat!"))
				H.visible_message(SPAN_DANGER("[H] lets out an unnatural croaking noise!"))
				playsound(get_turf(H), 'sounds/scp/306/croak.ogg', 30, TRUE)
			transformation_progress += 15

		if(3)
			if(transformation_progress >= 100)
				complete_transformation(H)
				return
			if(prob(50))
				H.adjustBruteLoss(5)
				H.Stun(5)
				to_chat(H, SPAN_DANGER("<b>Your mind grows foggy as animal instincts take over!</b>"))
				H.visible_message(SPAN_DANGER("[H] twitches spasmodically, limbs shortening!"))
			if(prob(40))
				H.Weaken(6)
				playsound(get_turf(H), 'sounds/scp/306/croak.ogg', 50, TRUE)
				H.visible_message(SPAN_DANGER("[H] emits a deafening croak!"))
			if(prob(20))
				H.adjustBrainLoss(3)
				to_chat(H, SPAN_DANGER("<i>Ribbit... ribbit...</i>"))
			transformation_progress += 25

/datum/disease/scp306/proc/complete_transformation(mob/living/carbon/human/H)
	H.visible_message(SPAN_DANGER("<b>[H.name]</b> finishes transforming into a giant frog!"))
	playsound(get_turf(H), 'sounds/scp/306/croak.ogg', 70, TRUE)

	var/mob/living/simple_animal/scp306_frog/frog = new(get_turf(H))

	if(H.mind)
		H.mind.transfer_to(frog)
		to_chat(frog, SPAN_DANGER("<b>You have fully transformed into a frog. You retain your mind, but your body is forever changed.</b>"))

	H.ghostize()
	qdel(H)

// ============================================================================
// INFECTION PROC
// ============================================================================

/mob/living/carbon/human/proc/infect_scp306()
	set name = "Infect SCP-306"
	set hidden = TRUE
	for(var/datum/disease/scp306/D in diseases)
		return FALSE
	// Don't infect SCPs
	if(SCP)
		return FALSE
	var/datum/disease/scp306/D = new()
	D.Infect(src, FALSE)
	visible_message(SPAN_DANGER("[src] is exposed to a strange viral agent!"))
	to_chat(src, SPAN_WARNING("You feel something cold spreading through your veins..."))
	return TRUE

// ============================================================================
// SCP-306 FROG
// ============================================================================

/mob/living/simple_animal/scp306_frog
	name = "giant frog"
	desc = "This toad looks suspiciously big."
	icon = 'icons/SCP/scp-306.dmi'
	icon_state = "frog"
	icon_living = "frog"
	icon_dead = "dead"
	icon_rest = "frog_lying"

	maxHealth = 200
	health = 200

	movement_cooldown = 4
	movement_sound = 'sounds/scp/306/squish.ogg'

	see_invisible = SEE_INVISIBLE_NOLIGHTING
	see_in_dark = 5

	can_be_buckled = TRUE
	response_help = "pets"
	response_disarm = "gently pushes aside"
	response_harm = "hits"

	var/infect_chance = 30

/mob/living/simple_animal/scp306_frog/Initialize(mapload)
	. = ..()
	add_language("Galactic Common")
	default_language = all_languages["Galactic Common"]

	SCP = new /datum/scp(
		src,
		"giant frog",
		SCP_KETER,
		"306",
	)
	add_verb(src, /client/proc/scpooc)
	SCP.min_time = 15 MINUTES
	SCP.min_playercount = 10

/mob/living/simple_animal/scp306_frog/Life()
	. = ..()
	if(stat == DEAD)
		icon_state = icon_dead
	else
		icon_state = resting ? icon_rest : icon_living

	if(prob(3) && stat != DEAD)
		playsound(src, 'sounds/scp/306/croak.ogg', 20, TRUE)

/mob/living/simple_animal/scp306_frog/say(message, datum/language/speaking = null, whispering)
	playsound(get_turf(src), 'sounds/scp/306/croak.ogg', 30, TRUE)
	to_chat(src, SPAN_WARNING("You cannot speak, you can only croak and ribbit."))
	return 0

/mob/living/simple_animal/scp306_frog/UnarmedAttack(atom/A)
	if(ishuman(A))
		var/mob/living/carbon/human/H = A
		// Don't infect SCPs
		if(H.SCP)
			return
		switch(a_intent)
			if(I_HELP)
				H.visible_message(SPAN_NOTICE("[src] hugs [H] with its sticky body!"), SPAN_NOTICE("[src] gives you a friendly hug!"))
				playsound(src, 'sounds/scp/306/squish.ogg', 40, TRUE)
				if(prob(infect_chance))
					H.infect_scp306()
					to_chat(H, SPAN_DANGER("You feel something foreign spreading through your skin..."))
			if(I_DISARM)
				H.visible_message(SPAN_WARNING("[src] bumps into [H]!"), SPAN_WARNING("[src] bumps into you!"))
				playsound(src, 'sounds/scp/306/squish.ogg', 30, TRUE)
				H.Weaken(2)
				if(prob(infect_chance))
					H.infect_scp306()
			if(I_HURT)
				H.visible_message(SPAN_WARNING("[src] slaps [H] weakly!"), SPAN_WARNING("[src] slaps you, but it's more annoying than painful."))
				playsound(src, 'sounds/scp/306/squish.ogg', 40, TRUE)
				H.apply_damage(5, BRUTE)
		return
	return ..()

/mob/living/simple_animal/scp306_frog/verb/Croak()
	set name = "Croak"
	set category = "SCP-306"
	set desc = "Let out a croak."

	playsound(src, 'sounds/scp/306/croak.ogg', 50, TRUE)
	visible_message(SPAN_NOTICE("[src] croaks loudly!"))

/mob/living/simple_animal/scp306_frog/verb/ToggleRest()
	set name = "Rest"
	set category = "SCP-306"

	resting = !resting
	if(resting)
		playsound(src, 'sounds/scp/306/squish.ogg', 15, TRUE)
		visible_message(SPAN_NOTICE("[src] crouches down low."))
	else
		playsound(src, 'sounds/scp/306/squish.ogg', 15, TRUE)
		visible_message(SPAN_NOTICE("[src] stands up."))
	update_icons()

/mob/living/simple_animal/scp306_frog/SelfMove(direction)
	resting = FALSE
	. = ..()

/mob/living/simple_animal/scp306_frog/update_icon()
	if(stat == DEAD)
		icon_state = icon_dead
	else
		icon_state = resting ? icon_rest : icon_living
