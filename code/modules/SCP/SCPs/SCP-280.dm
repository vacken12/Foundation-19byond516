/mob/living/simple_animal/hostile/scp280
	name = "Dark Mass"
	desc = "A human shaped-like mass of darkness."
	icon = 'icons/SCP/scp-280.dmi'
	icon_state = "scp_280"
	status_flags = NO_ANTAG

	pixel_x = -15
	default_pixel_x = -15 // Fix sprite pos

	see_invisible = SEE_INVISIBLE_NOLIGHTING
	see_in_dark = 7
	movement_cooldown = 6

	response_help = "tries to reach inside"
	response_disarm = "tries to push away"
	response_harm = "tries to punch"

	can_escape = TRUE //snip snip

	pass_flags = PASS_FLAG_TABLE
	density = FALSE

	mob_size = MOB_LARGE // Can't be pulled by human
	can_be_buckled = FALSE

	meat_type = null
	meat_amount = 0
	skin_material = null
	skin_amount = 0
	bone_material = null
	bone_amount = 0

	maxHealth = 400
	health = 400

	ai_holder_type = /datum/ai_holder/simple_animal/melee/scp280
	say_list_type = /datum/say_list/scp017 //they have like the same saylist so...

	natural_weapon = /obj/item/natural_weapon/claws/strongest // Quite a dangerous thing.

	hud_type = /datum/hud/animal_scp280

	//Mechanics

	var/regen_multiply = 2 // 20 HP per tick
	var/door_cooldown = 5 SECONDS
	var/door_cooldown_track
	var/area/spawn_area
	var/turf/start_turf = null

	///Our damage message cooldown
	var/damage_message_cooldown

/mob/living/simple_animal/hostile/scp280/Initialize()
	. = ..()
	SCP = new /datum/scp(
		src, // Ref to actual SCP atom
		"dark mass", //Name (Should not be the scp desg, more like what it can be described as to viewers)
		SCP_KETER, //Obj Class
		"280", //Numerical Designation
		SCP_PLAYABLE // [SCP 280 can be played by player]
	)
	add_verb(src, /client/proc/scpooc)

	spawn_area = get_area(src)
	start_turf = get_turf(src)

	SCP.min_time = 15 MINUTES
	SCP.min_playercount = 30

//AI stuff

/datum/ai_holder/simple_animal/melee/scp280
	can_flee = TRUE
	flee_when_dying = TRUE
	dying_threshold = 0.5

	var/turf/shadow_target
	var/list/darkness_path = list()

/datum/ai_holder/simple_animal/melee/scp280/special_flee_check()
	var/turf/our_turf = get_turf(holder)
	if(!is_dark(our_turf))
		return TRUE

/datum/ai_holder/simple_animal/melee/scp280/proc/flee_to_darkness()
	ai_log("flee_to_darkness() : Entering.", AI_LOG_DEBUG)
	if(!shadow_target || !LAZYLEN(darkness_path))
		LAZYCLEARLIST(darkness_path)
		LAZYINITLIST(darkness_path)
		var/while_loop_timeout = world.time
		while(!LAZYLEN(darkness_path) && ((world.time - while_loop_timeout) < 5 SECONDS))
			shadow_target = pick_turf_in_range(holder.loc, 14, list(GLOBAL_PROC_REF(is_dark)))
			darkness_path = get_path_to(holder, shadow_target)
	if(!should_flee() || !shadow_target || !LAZYLEN(darkness_path) || !holder.IMove(darkness_path[1]))
		ai_log("flee_to_darkness() : Lost target to flee to.", AI_LOG_INFO)
		shadow_target = null
		LAZYCLEARLIST(darkness_path)
		set_stance(STANCE_IDLE)
		ai_log("flee_to_darkness() : Exiting.", AI_LOG_DEBUG)
		return

	ai_log("flee_to_darkness() : Stepping to shadow target.", AI_LOG_TRACE)
	for(var/steps = 0, steps < 5, steps++)
		if(!LAZYLEN(darkness_path))
			break
		step_towards(holder, darkness_path[1], vision_range)
		if(holder.loc != darkness_path[1])
			break
		LAZYREMOVE(darkness_path, darkness_path[1])
	ai_log("flee_to_darkness() : Exiting.", AI_LOG_DEBUG)

/datum/ai_holder/simple_animal/melee/scp280/flee_from_target()
	if(!target)
		flee_to_darkness()
	else
		return ..()

/datum/ai_holder/simple_animal/melee/scp280/can_attack(atom/movable/the_target, vision_required = TRUE)
	if(the_target.SCP)
		return ATTACK_FAILED
	var/turf/Tturf = get_turf(the_target)
	if(!is_dark(Tturf))
		return ATTACK_FAILED
	return ..()

//Mechanics

/mob/living/simple_animal/hostile/scp280/Life()
	. = ..()
	var/turf/our_turf = get_turf(src)
	if(!our_turf)
		return
	var/lumcount = our_turf.get_lumcount()
	if(!is_dark(our_turf))
		if(alpha != 255)
			to_chat(src, SPAN_WARNING("In the light your camouflage disappears!"))
			alpha = 255

		adjustBruteLoss(60 * lumcount) // DAMAGE CHANGED 80 -> 60
		movement_cooldown = 7 // The light slows down

		if((world.time - damage_message_cooldown) > 2 SECONDS)
			visible_message(SPAN_WARNING("[src] is singed by the light!"))
			damage_message_cooldown = world.time
		if(!ai_holder.target)
			ai_holder.set_stance(STANCE_FLEE)
			return
	else
		if(alpha != 100)
			to_chat(src, SPAN_WARNING("You merge with the surrounding darkness!"))
			alpha = 100

		movement_cooldown = 1 // In the dark it becomes faster
		if (health < maxHealth)
			adjustBruteLoss(-10 * regen_multiply) // 20 HP per tick

	if(lumcount >= 0.6)
		ai_holder.set_stance(STANCE_FLEE)

	// Prevent health from dropping below 10%
	if(health <= 40)
		health = 40

//Overrides

/mob/living/simple_animal/hostile/scp280/bullet_act(obj/item/projectile/Proj)
	if(Proj.damage_type == BRUTE)
		visible_message(SPAN_WARNING("The [Proj] seems to pass right through it!"))
		return PROJECTILE_CONTINUE
	return ..()

/mob/living/simple_animal/hostile/scp280/attack_hand(mob/living/carbon/human/M)
	to_chat(M, SPAN_WARNING("Your hand goes right through [src]!"))

/mob/living/simple_animal/hostile/scp280/attackby(obj/item/O, mob/user)
	to_chat(user, SPAN_WARNING("The [O] goes right through [src]!"))

/mob/living/simple_animal/hostile/scp280/IMove(turf/newloc, safety = TRUE)
	var/area/Tarea = get_area(newloc)
	var/turf/ourTurf = get_turf(src)
	var/list/turf/adjacent_turfs = ourTurf.AdjacentTurfs()

	var/dark_spot_avalible = FALSE
	for(var/turf/Tturf in adjacent_turfs)
		if(is_dark(Tturf))
			dark_spot_avalible = TRUE
			break

	if((!is_dark(newloc) || (Tarea.dynamic_lighting == 0)) && dark_spot_avalible) //We dont go to turfs which are lit unless we have no choice.
		return MOVEMENT_FAILED
	return ..()

/mob/living/simple_animal/hostile/scp280/death(gibbed, deathmessage = "dissapears in a puff of smoke", show_dead_message)
	var/turf/T = get_turf(src)

	var/datum/effect/effect/system/smoke_spread/S = new/datum/effect/effect/system/smoke_spread()
	S.set_up(3,0,T)
	S.start()

	var/turf/new_target_turf = pick_turf_in_range(T, 15, list(GLOBAL_PROC_REF(isfloor), GLOBAL_PROC_REF(is_dark)))
	if(new_target_turf)
		forceMove(new_target_turf)
		health = 40 // 10% HP
		return
	else if(spawn_area) // If there save area, we return to it.
		forceMove(spawn_area)
		health = 40 // 10% HP
		return
	else
		ghostize() // Catch wrong state...
		qdel_self()

/mob/living/simple_animal/hostile/scp280/proc/OpenDoor(obj/machinery/door/A)
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


	if(!is_dark(get_turf(A)) && istype(A, /obj/machinery/door/blast))
		to_chat(src, SPAN_WARNING("The light is shining on this"))
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

	A.visible_message(SPAN_WARNING("\The [src] begins to pry open \the [A]!"))
	playsound(get_turf(A), 'sounds/machines/airlock_creaking.ogg', 35, 1)
	door_cooldown_track = world.time + open_time // To avoid sound spam

	if(!do_after(src, open_time, A))
		return

	if(istype(A, /obj/machinery/door/blast))
		var/obj/machinery/door/blast/DB = A
		DB.visible_message(SPAN_DANGER("\The [src] forcefully opens \the [DB]!"))
		DB.force_open()
		return

	if(istype(A, /obj/machinery/door/airlock))
		var/obj/machinery/door/airlock/AR = A
		AR.unlock(TRUE) // No more bolting in the SCPs and calling it a day
		AR.welded = FALSE

	A.set_broken(TRUE)
	A.do_animate("spark")
	var/check = A.open(1)
	visible_message("\The [src] slices \the [A]'s controls[check ? ", ripping it open!" : ", breaking it!"]")

// Override

/mob/living/simple_animal/hostile/scp280/UnarmedAttack(atom/A, proximity)
	setClickCooldown(CLICK_CD_ATTACK)

	if(A.SCP)
		to_chat(src, SPAN_WARNING(SPAN_ITALIC("That thing is not like the others. You know better than to mess with it.")))
		return

	if(istype(A,/mob/living))
		if(!get_natural_weapon())
			custom_emote(1,"[friendly] [A]!")
			return
		if(ckey)
			admin_attack_log(src, A, "Has attacked its victim.", "Has been attacked by its attacker.")

	if(istype(A, /obj/machinery/door))
		OpenDoor(A) // Open the door!
	else
		A.attackby(get_natural_weapon(), src)

/mob/living/simple_animal/hostile/handle_regular_hud_updates()
	update_sight()
	if (healths)
		if (stat != 2)
			switch(health)
				if(400 to INFINITY)
					healths.icon_state = "health0"
				if(350 to 400)
					healths.icon_state = "health1"
				if(300 to 350)
					healths.icon_state = "health2"
				if(200 to 300)
					healths.icon_state = "health3"
				if(100 to 200)
					healths.icon_state = "health4"
				if(0 to 100)
					healths.icon_state = "health5"
				else
					healths.icon_state = "health6"
		else
			healths.icon_state = "health7"

	if(stat != DEAD)
		if (machine)
			if (!(machine.check_eye(src)))
				reset_view(null)
		else
			if(client && !client.adminobs)
				reset_view(null)

	return 1

/datum/hud/animal_scp280/FinalizeInstantiation(ui_style='icons/mob/screen/white.dmi', ui_color = "#ffffff", ui_alpha = 255)
	mymob.client.screen = list()

	action_intent = new /atom/movable/screen/intent()

	mymob.healths = new /atom/movable/screen()
	mymob.healths.icon = ui_style
	mymob.healths.icon_state = "health0"
	mymob.healths.SetName("health")
	mymob.healths.screen_loc = ui_health

	mymob.client.screen |= action_intent
	mymob.client.screen |= mymob.healths
