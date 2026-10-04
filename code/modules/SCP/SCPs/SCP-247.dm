/mob/living/simple_animal/hostile/scp247
	name = "cute kitty"
	desc = "A cute cat."
	icon = 'icons/scp/scp-247.dmi'

	icon_state = "scp-247"
	icon_living = "scp-247"
	icon_dead = "dead"

	maxHealth = 300
	health = 300

	response_help = "pets the"
	response_disarm = "gently pushes aside the"
	response_harm = "hits the"

	harm_intent_damage = 5

	ai_holder_type = /datum/ai_holder/simple_animal/melee/evasive/scp247
	say_list_type = /datum/say_list/cat

	natural_weapon = /obj/item/natural_weapon/bite/strong

	var/turf/start_turf = null

	//config

	///minimium distance we have to be away in order to be able to fire on scp 247
	var/min_fire_distance = 3

	///Is SCP-247 currently pacified?
	var/pacified = FALSE
	///How long pacify lasts
	var/pacify_duration = 3 MINUTES

/mob/living/simple_animal/hostile/scp247/Initialize()
	. = ..()
	SCP = new /datum/scp(
		src, // Ref to actual SCP atom
		"cute kitty", //Name (Should not be the scp desg, more like what it can be described as to viewers)
		SCP_EUCLID, //Obj Class
		"247", //Numerical Designation
		SCP_PLAYABLE
	)
	add_verb(src, /client/proc/scpooc)
	add_verb(src, /mob/living/simple_animal/hostile/scp247/verb/purr)

	SCP.min_time = 30 MINUTES
	SCP.min_playercount = 18

	start_turf = get_turf(src)

// AI

/datum/ai_holder/simple_animal/melee/evasive/scp247
	returns_home = TRUE
	mauling = TRUE
	handle_corpse = TRUE
	home_low_priority = TRUE
	intelligence_level = AI_SMART
	use_astar = TRUE

/datum/ai_holder/simple_animal/melee/evasive/scp247/New()
	. = ..()
	home_turf = get_turf(holder)

/datum/ai_holder/simple_animal/melee/evasive/scp247/can_attack(atom/movable/the_target, vision_required = TRUE)
	var/mob/living/simple_animal/hostile/scp247/owner = holder
	if(owner && owner.pacified)
		return ATTACK_FAILED
	return ..()

// Verbs

/mob/living/simple_animal/hostile/scp247/verb/purr()
	set name = "Purr"
	set category = "SCP-247"
	set desc = "Let out a cute purr."

	if(world.time < last_special + 2 SECONDS)
		to_chat(src, SPAN_WARNING("You purred too recently!"))
		return

	var/sound_file = pick(list(
		'sounds/scp/247/purr1.ogg',
		'sounds/scp/247/purr2.ogg',
		'sounds/scp/247/purr3.ogg',
		'sounds/scp/247/purr4.ogg'
	))
	playsound(src, sound_file, 50, 1)
	visible_message(SPAN_NOTICE("[src] purrs softly."))
	last_special = world.time

// Overrides

/mob/living/simple_animal/hostile/scp247/bullet_act(obj/item/projectile/Proj) //This is a little bad but its the best way to keep this localized within 247
	if(Proj.damage && !Proj.nodamage && ishuman(Proj.firer) && (get_dist(Proj.firer, src) <= min_fire_distance))
		to_chat(Proj.firer, SPAN_WARNING(SPAN_BOLD("You cannot bear to fire at [src], and you miss intentionally!")))
		return PROJECTILE_FORCE_MISS
	else
		return ..()

/mob/living/simple_animal/hostile/scp247/attack_hand(mob/living/carbon/human/M)
	if(M.a_intent == I_HURT)
		to_chat(M, SPAN_WARNING(SPAN_BOLD("Why would you want to attack such a cute kitty?")))
		return
	else
		return ..()

/mob/living/simple_animal/hostile/scp247/attackby(obj/item/O, mob/user)
	if(istype(O, /obj/item/reagent_containers/food/snacks/meat))
		if(pacified)
			to_chat(user, SPAN_WARNING("[src] is already full!"))
			return
		to_chat(user, SPAN_NOTICE("You feed [src] some meat."))
		visible_message(SPAN_NOTICE("[src] happily eats the meat, purring gently."))
		// Heal
		var/heal_amt = 30
		if(istype(O, /obj/item/reagent_containers/food/snacks/meat/human))
			heal_amt = 40
		adjustBruteLoss(-heal_amt)
		adjustFireLoss(-heal_amt)
		adjustToxLoss(-heal_amt)
		adjustOxyLoss(-heal_amt)
		// Pacify
		pacified = TRUE
		addtimer(CALLBACK(src, PROC_REF(remove_pacify)), pacify_duration)
		// Remove meat
		qdel(O)
		return
	return ..()

/mob/living/simple_animal/hostile/scp247/ClickOn(atom/A, params)
	if(istype(A, /obj/item/reagent_containers/food/snacks/meat) && Adjacent(A))
		if(pacified)
			to_chat(src, SPAN_WARNING("You are already full!"))
			return
		var/obj/item/reagent_containers/food/snacks/meat/M = A
		visible_message(SPAN_NOTICE("[src] eats [M]."))
		var/heal_amt = 30
		if(istype(M, /obj/item/reagent_containers/food/snacks/meat/human))
			heal_amt = 40
		adjustBruteLoss(-heal_amt)
		adjustFireLoss(-heal_amt)
		adjustToxLoss(-heal_amt)
		adjustOxyLoss(-heal_amt)
		pacified = TRUE
		addtimer(CALLBACK(src, PROC_REF(remove_pacify)), pacify_duration)
		qdel(M)
		return
	..()

/mob/living/simple_animal/hostile/scp247/proc/remove_pacify()
	pacified = FALSE
	visible_message(SPAN_WARNING("[src]'s eyes narrow and it looks hungry again."))

/mob/living/simple_animal/hostile/scp247/UnarmedAttack(atom/A)
	if(pacified)
		to_chat(src, SPAN_NOTICE("You are too full and calm to attack right now."))
		return
	// If target is a dead mob, consume it for healing
	if(ismob(A))
		var/mob/target = A
		if(target.stat == DEAD)
			visible_message(SPAN_DANGER("[src] pounces on [target] and begins feasting!"))
			if(do_after(src, 3 SECONDS, target))
				var/heal_amt = 60
				if(ishuman(target))
					heal_amt = 80
				adjustBruteLoss(-heal_amt)
				adjustFireLoss(-heal_amt)
				adjustToxLoss(-heal_amt)
				adjustOxyLoss(-heal_amt)
				pacified = TRUE
				addtimer(CALLBACK(src, PROC_REF(remove_pacify)), pacify_duration)
				target.ghostize()
				qdel(target)
			return
	return ..()
