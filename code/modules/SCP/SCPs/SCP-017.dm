/mob/living/simple_animal/hostile/scp017
	name = "shambling void"
	desc = "A weird shambling void. You can see nothing inside."
	icon = 'icons/SCP/scp-017.dmi'

	icon_state = "scp-017"
	response_help = "tries to reach inside"
	response_disarm = "tries to push away"
	response_harm = "tries to punch"

	can_escape = TRUE //snip snip
	pass_flags = PASS_FLAG_TABLE
	density = FALSE

	meat_type = null
	meat_amount = 0
	skin_material = null
	skin_amount = 0
	bone_material = null
	bone_amount = 0

	maxHealth = 100
	health = 100

	movement_cooldown = 2

	see_invisible = SEE_INVISIBLE_NOLIGHTING
	see_in_dark = 7

	say_list_type = /datum/say_list/scp017
	ai_holder_type = /datum/ai_holder/simple_animal/melee/scp017

	can_bleed = FALSE

	//Config

	///lumcount required for something to be considered a shadow
	var/shadow_threshold = 0.4
	///Door open cooldown
	var/door_cooldown_track = 0
	///Door open cooldown
	var/door_cooldown = 5 SECONDS

/mob/living/simple_animal/hostile/scp017/Initialize()
	. = ..()
	SCP = new /datum/scp(
		src, // Ref to actual SCP atom
		"shambling void", //Name (Should not be the scp desg, more like what it can be described as to viewers)
		SCP_KETER, //Obj Class
		"017", //Numerical Designation
	)

//Datum proc overrides and defines
/datum/ai_holder/simple_animal/melee/scp017
	cooperative = FALSE
	speak_chance = 1
	mauling = TRUE
	destructive = TRUE
	returns_home = FALSE
	can_flee = FALSE
	respect_confusion = FALSE
	vision_range = 10
	///lumcount required for something to be considered a shadow. Should be identical to mob value.
	var/shadow_threshold = 0.4

/datum/ai_holder/simple_animal/melee/scp017/can_attack(atom/movable/the_target, vision_required = TRUE)
	if(!..() || the_target.SCP)
		return ATTACK_FAILED
	var/turf/Tturf = get_turf(the_target)
	if(!Tturf || !is_dark(Tturf, shadow_threshold))
		return ATTACK_FAILED
	return ..()

/datum/say_list/scp017
	emote_hear = list("wooshes","whispers")
	emote_see = list("shambles", "shimmers")

//Mob procs
/mob/living/simple_animal/hostile/scp017/IMove(turf/newloc, safety = TRUE)
	if(!newloc || !is_dark(newloc, shadow_threshold))
		to_chat(src, SPAN_WARNING("You cannot move into the light!"))
		return MOVEMENT_FAILED
	return ..()

/mob/living/simple_animal/hostile/scp017/gib()
	return FALSE

/mob/living/simple_animal/hostile/scp017/dust()
	return FALSE

//Death

/mob/living/simple_animal/hostile/scp017/death(gibbed, deathmessage = "dissapears in a puff of smoke", show_dead_message)
	. = ..()
	var/turf/T = get_turf(src)

	var/datum/effect/effect/system/smoke_spread/S = new/datum/effect/effect/system/smoke_spread()
	S.set_up(3,0,T)
	S.start()

	ghostize()
	qdel(src)

/mob/living/simple_animal/hostile/scp017/bullet_act(obj/item/projectile/Proj)
	if(Proj.damage_type == BRUTE)
		visible_message(SPAN_WARNING("The [Proj] seems to pass right through it!"))
		return PROJECTILE_CONTINUE
	return ..()

//Consume proc
/mob/living/simple_animal/hostile/scp017/proc/try_consume(atom/movable/A)
	if(!A || A == src || A.SCP)
		return
	if(isturf(A))
		return
	var/death_message = pick("[A] disappears into [src]!", "[A] is enveloped by [src]!", "[A] is absorbed by [src]!")
	visible_message(SPAN_DANGER(death_message))
	// Smoke effect on consume
	var/turf/T = get_turf(src)
	var/datum/effect/effect/system/smoke_spread/S = new/datum/effect/effect/system/smoke_spread()
	S.set_up(3,0,T)
	S.start()
	if(ismob(A))
		var/mob/target = A
		target.ghostize()
		qdel(target)
	else
		qdel(A)

//Open doors
/mob/living/simple_animal/hostile/scp017/proc/OpenDoor(obj/machinery/door/A)
	if((world.time - door_cooldown_track) < door_cooldown)
		to_chat(src, SPAN_WARNING("You cant open another door just yet!"))
		return

	if(!istype(A))
		return

	if(!A.density)
		return

	if(!A.Adjacent(src))
		to_chat(src, SPAN_WARNING("\The [A] is too far away."))
		return

	if(!is_dark(get_turf(A)))
		to_chat(src, SPAN_WARNING("The light is shining on this door!"))
		return

	var/open_time = 10 SECONDS

	if(istype(A, /obj/machinery/door/airlock))
		var/obj/machinery/door/airlock/AR = A
		if(AR.locked)
			open_time += 3 SECONDS
		if(AR.welded)
			open_time += 3 SECONDS
		if(AR.secured_wires)
			open_time += 3 SECONDS

	if(istype(A, /obj/machinery/door/airlock/highsecurity))
		open_time += 6 SECONDS

	if(istype(A, /obj/machinery/door/blast))
		to_chat(src, SPAN_WARNING("The door is hard to open."))
		open_time += 15 SECONDS // Such a strong door...

	A.visible_message(SPAN_WARNING("\The [src] begins to absorb \the [A]!"))
	playsound(get_turf(A), 'sounds/machines/airlock_creaking.ogg', 35, 1)
	door_cooldown_track = world.time + open_time // To avoid sound spam

	if(!do_after(src, open_time, A))
		return

	var/turf/T = get_turf(A)
	var/datum/effect/effect/system/smoke_spread/S = new/datum/effect/effect/system/smoke_spread()
	S.set_up(3,0,T)
	S.start()

	if(istype(A, /obj/machinery/door/blast))
		var/obj/machinery/door/blast/DB = A
		DB.visible_message(SPAN_DANGER("\The [src] absorbs \the [DB]!"))
		visible_message(SPAN_DANGER("\The [A] disappears into [src]!"))
		qdel(A)
		return

	if(istype(A, /obj/machinery/door/airlock))
		var/obj/machinery/door/airlock/AR = A
		AR.unlock(TRUE)
		AR.welded = FALSE

	A.set_broken(TRUE)
	A.do_animate("spark")
	var/check = A.open(1)
	visible_message("\The [src] absorbs \the [A]'s controls[check ? ", ripping it open!" : ", breaking it!"]")
	qdel(A)

//Attack

/mob/living/simple_animal/hostile/scp017/UnarmedAttack(atom/A)
	if(!A || A == src || isstructure(A) || ismachinery(A) || A.density)
		return
	if(istype(A, /obj/machinery/door))
		OpenDoor(A)
		return
	try_consume(A)

/mob/living/simple_animal/hostile/scp017/Move(turf/newloc, direction)
	. = ..()
	if(!. && newloc && is_dark(newloc, shadow_threshold))
		forceMove(newloc)
		return TRUE
	return .

//General Interactions
/mob/living/simple_animal/hostile/scp017/attack_hand(mob/living/carbon/human/M)
	. = ..()
	if(!M)
		return
	switch(M.a_intent)
		if(I_HELP)
			if(prob(15))
				try_consume(M)
		if(I_HURT)
			if(prob(85))
				try_consume(M)
		if(I_DISARM)
			if(prob(10))
				try_consume(M)
		if(I_GRAB)
			if(prob(20))
				try_consume(M)

/mob/living/simple_animal/hostile/scp017/attackby(obj/item/O, mob/user)
	. = ..()
	if(!O)
		return
	if(istype(O, /obj/item/grenade) || istype(O, /obj/item/weapon))
		try_consume(O)
	if(user)
		try_consume(user)

/mob/living/simple_animal/hostile/scp017/hitby(atom/movable/AM, datum/thrownthing/TT)
	. = ..()
	if(!AM)
		return
	try_consume(AM)
	if(ismob(AM))
		try_consume(AM)

/mob/living/simple_animal/hostile/scp017/attack_target(atom/A)
	if(!A)
		return
	try_consume(A)
