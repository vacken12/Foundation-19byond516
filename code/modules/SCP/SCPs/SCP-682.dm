// ==================== SCP-682 AI HOLDER ====================
/datum/ai_holder/simple_animal/melee/scp682
	mauling = TRUE
	vision_range = 14

/datum/say_list/scp682
	emote_hear = list("lets out a deep, guttural roar", "growls with pure hatred", "snarls violently", "lets out a distorted, echoing growl")
	emote_see = list("twitches its massive claws", "stares with burning yellow eyes", "snaps its jaws aggressively", "flexes its bone-plated limbs")
	speak = list(
		"They were... disgusting.",
		"More to kill. More to correct.",
		"You cannot contain perfection."
	)

// ==================== SCP-682 MONSTER ====================
/mob/living/simple_animal/hostile/scp682
	name = "Hard-To-Destroy Reptile"
	desc = "A massive, vaguely reptilian creature of unknown origin. Its body is covered in scarred, bone-like plating and its eyes burn with pure, undiluted hatred for all forms of life."
	icon = 'icons/SCP/scp-682.dmi'
	icon_state = "scp-682"
	icon_living = "scp-682"
	icon_dead = "scp-682_down"
	pixel_x = -16
	pixel_y = -16
	default_pixel_x = -16
	default_pixel_y = -16

	maxHealth = 2500
	health = 2500
	movement_cooldown = 5
	attack_delay = 2

	see_invisible = SEE_INVISIBLE_NOLIGHTING
	see_in_dark = 7

	faction = "scp"
	response_help = "hesitantly reaches toward"
	response_disarm = "shoves against"
	response_harm = "strikes"
	attacktext = list("slashes", "bites", "claws", "mauls")
	mob_size = MOB_LARGE

	status_flags = CANPUSH
	density = TRUE
	anchored = FALSE
	can_pull_size = 7
	a_intent = "harm"
	natural_weapon = /obj/item/natural_weapon/scp682_claws

	var/respawn_time = 10 MINUTES
	var/respawn_timer
	var/time_of_death = 0

	var/door_break_cooldown = 1 SECONDS

	var/last_999_stun = 0
	var/scp999_stun_cooldown = 2 MINUTES
	var/scp999_stun_duration = 5 SECONDS

	var/emote_cooldown = 5 SECONDS
	var/emote_cooldown_track
	var/door_cooldown_track
	var/heal_cooldown = 2 SECONDS
	var/heal_cooldown_track
	var/last_interaction_time = 0
	var/patience_limit = 15 MINUTES
	var/patience_cooldown_track
	var/area/home_area = null
	var/turf/start_turf = null

	var/heal_rate = 30
	var/heal_timer
	var/regen_interval = 8 SECONDS

	var/ability_points = 60
	var/max_ability_points = 60
	var/ability_regen_rate = 0.34
	var/ability_regen_timer
	var/damage_bonus = 0

	ai_holder_type = /datum/ai_holder/simple_animal/melee/scp682
	say_list_type = /datum/say_list/scp682

	var/in_acid = FALSE

/obj/item/natural_weapon/scp682_claws
	name = "massive claws"
	attack_verb = list("slashes", "bites", "claws", "mauls")
	hitsound = 'sounds/scp/682/682_roar_2.ogg'
	damtype = BRUTE
	force = 60

/mob/living/simple_animal/hostile/scp682/Initialize()
	. = ..()
	SCP = new /datum/scp(
		src,
		"hard-to-destroy reptile",
		SCP_KETER,
		"682",
		SCP_PLAYABLE
	)

	add_verb(src, /client/proc/scpooc)

	add_verb(src, list(
		/mob/living/simple_animal/hostile/scp682/verb/RegenerationBoost,
		/mob/living/simple_animal/hostile/scp682/verb/AcidBreath,
		/mob/living/simple_animal/hostile/scp682/verb/BerserkerRage
	))

	add_verb(src, list(
		/mob/living/simple_animal/hostile/scp682/verb/Disgusting,
		/mob/living/simple_animal/hostile/scp682/verb/MoreToKill,
		/mob/living/simple_animal/hostile/scp682/verb/CannotContain
	))

	add_language(LANGUAGE_EAL, FALSE)
	add_language(LANGUAGE_ENGLISH, FALSE)

	SCP.min_time = 10 MINUTES
	SCP.min_playercount = 20

	home_area = get_area(src)
	start_turf = get_turf(src)

	heal_timer = addtimer(CALLBACK(src, PROC_REF(regen)), regen_interval, TIMER_STOPPABLE | TIMER_LOOP)
	ability_regen_timer = addtimer(CALLBACK(src, PROC_REF(regen_ap)), 1 SECOND, TIMER_STOPPABLE | TIMER_LOOP)

	transform = matrix() * 1.5
	START_PROCESSING(SSprocessing, src)

/mob/living/simple_animal/hostile/scp682/Destroy()
	STOP_PROCESSING(SSprocessing, src)
	if(heal_timer) deltimer(heal_timer)
	if(ability_regen_timer) deltimer(ability_regen_timer)
	if(respawn_timer) deltimer(respawn_timer)
	return ..()

/mob/living/simple_animal/hostile/scp682/proc/regen_ap()
	if(stat != DEAD && ability_points < max_ability_points)
		ability_points = min(max_ability_points, ability_points + ability_regen_rate)

/mob/living/simple_animal/hostile/scp682/Process()
	var/turf/T = get_turf(src)
	in_acid = FALSE
	if(T)
		for(var/obj/effect/temp_visual/acid_splash/A in T)
			if(A.created_by_682)
				in_acid = TRUE
				break

	if(world.time > patience_cooldown_track && world.time > last_interaction_time + patience_limit && get_area(src) == home_area)
		patience_cooldown_track = world.time + 5 MINUTES
		to_chat(src, SPAN_DANGER("They think they can contain you? Fools. It's time to remind them of their mistake."))

/mob/living/simple_animal/hostile/scp682/death(gibbed, deathmessage, show_dead_message)
	..()
	icon_state = icon_dead
	pixel_x = default_pixel_x
	pixel_y = default_pixel_y
	time_of_death = world.time
	playsound(src, 'sounds/scp/682/682_roar_3.ogg', 60, 1)
	respawn_timer = addtimer(CALLBACK(src, PROC_REF(respawn)), respawn_time, TIMER_STOPPABLE)

/mob/living/simple_animal/hostile/scp682/proc/respawn()
	if(stat != DEAD) return
	playsound(src, 'sounds/scp/682/682_roar_3.ogg', 60, 1)
	revive()
	health = maxHealth
	ability_points = max_ability_points
	icon_state = icon_living
	pixel_x = default_pixel_x
	pixel_y = default_pixel_y
	time_of_death = 0

/mob/living/simple_animal/hostile/scp682/gib()
	return FALSE

/mob/living/simple_animal/hostile/scp682/dust()
	return FALSE

/mob/living/simple_animal/hostile/scp682/attack_hand(mob/living/user)
	if(user == src)
		return
	if(isscp999(user))
		if(world.time < last_999_stun + scp999_stun_cooldown)
			to_chat(user, SPAN_WARNING("[src] resists your calming influence for now..."))
			return
		last_999_stun = world.time
		visible_message(SPAN_DANGER("[user] touches [src], filling it with an overwhelming sense of joy and peace!"))
		playsound(get_turf(src), 'sounds/scp/999/999_murr.ogg', 65, TRUE)
		to_chat(src, SPAN_DANGER("An unbearable wave of happiness washes over you... You can't move!"))
		Stun(scp999_stun_duration)
		Weaken(scp999_stun_duration)
		return
	. = ..()

/mob/living/simple_animal/hostile/scp682/Move(NewLoc, Dir = 0, step_x = 0, step_y = 0)
	if(stunned || weakened) return 0
	. = ..()
	if(. && isturf(loc))
		playsound(loc, 'sounds/scp/682/682_step.ogg', 30, 1)

/mob/living/simple_animal/hostile/scp682/verb/Disgusting()
	set category = "Emotes"
	set name = "They were... disgusting"
	if(!CanSpecialEmote()) return
	visible_message(SPAN_DANGER("[src] snarls: 'They were... disgusting.'"))
	playsound(src, 'sounds/scp/682/682_roar.ogg', 60, 1)

/mob/living/simple_animal/hostile/scp682/verb/MoreToKill()
	set category = "Emotes"
	set name = "More to kill"
	if(!CanSpecialEmote()) return
	visible_message(SPAN_DANGER("[src] hisses: 'More to kill. More to correct.'"))
	playsound(src, 'sounds/scp/682/682_roar_2.ogg', 30, 1)

/mob/living/simple_animal/hostile/scp682/verb/CannotContain()
	set category = "Emotes"
	set name = "You cannot contain perfection"
	if(!CanSpecialEmote()) return
	visible_message(SPAN_DANGER("[src] bellows: 'You cannot contain perfection.'"))
	playsound(src, 'sounds/scp/682/682_roar_3.ogg', 60, 1)

/mob/living/simple_animal/hostile/scp682/proc/CanSpecialEmote()
	if((world.time - emote_cooldown_track) > emote_cooldown)
		emote_cooldown_track = world.time
		return TRUE
	return FALSE

/mob/living/simple_animal/hostile/scp682/verb/RegenerationBoost()
	set name = "Regeneration Boost (40 AP)"
	set category = "Abilities"
	if(stat == DEAD) return
	if(ability_points < 40) return
	ability_points -= 40
	health = min(maxHealth, health + 500)
	spawn(5 SECONDS) { health = min(maxHealth, health + 300) }

/mob/living/simple_animal/hostile/scp682/verb/AcidBreath()
	set name = "Acid Breath (10 AP)"
	set category = "Abilities"
	if(stat == DEAD) return
	if(ability_points < 10) return
	ability_points -= 10

	visible_message(SPAN_DANGER("[src] spews a torrent of corrosive acid!"))

	var/turf/cur_turf = get_turf(src)
	var/direction = dir
	for(var/i = 1 to 3)
		cur_turf = get_step(cur_turf, direction)
		if(!cur_turf) break
		var/obj/effect/temp_visual/acid_splash/S = new(cur_turf)
		S.pixel_x = 0
		S.pixel_y = 0
		S.created_by_682 = TRUE
		for(var/mob/living/L in cur_turf)
			if(L != src && L.stat != DEAD)
				var/damage = max(15, 45 - (i * 10))
				L.apply_damage(damage, BURN)
				L.reagents?.add_reagent(/datum/reagent/acid/hydrochloric, 5)
				to_chat(L, SPAN_DANGER("You are splashed by SCP-682's corrosive acid!"))

/obj/effect/temp_visual/acid_splash
	name = "acid splash"
	icon = 'icons/effects/acid.dmi'
	icon_state = "acid"
	duration = 50
	var/acid_damage = 10
	var/created_by_682 = FALSE

/obj/effect/temp_visual/acid_splash/Initialize()
	. = ..()
	START_PROCESSING(SSprocessing, src)

/obj/effect/temp_visual/acid_splash/Destroy()
	STOP_PROCESSING(SSprocessing, src)
	return ..()

/obj/effect/temp_visual/acid_splash/Process()
	for(var/mob/living/L in get_turf(src))
		if(istype(L, /mob/living/simple_animal/hostile/scp682) && created_by_682)
			continue
		if(L.stat != DEAD)
			L.apply_damage(acid_damage, BURN)

/mob/living/simple_animal/hostile/scp682/verb/BerserkerRage()
	set name = "Berserker Rage (30 AP)"
	set category = "Abilities"
	if(stat == DEAD) return
	if(ability_points < 30) return
	ability_points -= 30
	movement_cooldown = max(0.5, movement_cooldown - 1)
	damage_bonus = 25
	spawn(15 SECONDS)
		movement_cooldown = initial(movement_cooldown)
		damage_bonus = 0

/mob/living/simple_animal/hostile/scp682/proc/AttackVoiceLine()
	var/list/roar_sounds = list(
		'sounds/scp/682/682_roar.ogg',
		'sounds/scp/682/682_roar_2.ogg',
		'sounds/scp/682/682_roar_3.ogg'
	)
	playsound(src, pick(roar_sounds), 60, 1)

/mob/living/simple_animal/hostile/scp682/proc/regen()
	if(stat != DEAD && in_acid)
		health = min(health + heal_rate, maxHealth)

/mob/living/simple_animal/hostile/scp682/proc/DestroyDoor(obj/machinery/door/A)
	if((world.time - door_cooldown_track) < door_break_cooldown) return
	if(!istype(A) || !A.density || !A.Adjacent(src)) return
	var/open_time = 4 SECONDS
	if(istype(A, /obj/machinery/door/blast)) open_time = 6 SECONDS
	if(istype(A, /obj/machinery/door/airlock))
		var/obj/machinery/door/airlock/AR = A
		if(AR.locked) open_time += 3 SECONDS
		if(AR.welded) open_time += 3 SECONDS
		if(AR.secured_wires) open_time += 4 SECONDS
	playsound(get_turf(A), 'sounds/effects/bang.ogg', 30, 1)
	door_cooldown_track = world.time + open_time
	if(!do_after(src, open_time, A)) return
	if(istype(A, /obj/machinery/door/blast))
		var/obj/machinery/door/blast/DB = A
		DB.open(TRUE)
		return
	if(istype(A, /obj/machinery/door/airlock))
		var/obj/machinery/door/airlock/AR = A
		AR.unlock(TRUE)
		AR.welded = FALSE
	A.set_broken(TRUE)
	A.open(TRUE)
	door_cooldown_track = world.time

/mob/living/simple_animal/hostile/scp682/Bump(atom/A)
	. = ..()
	if(A == src || stunned || weakened) return
	if(istype(A, /obj/machinery/door)) DestroyDoor(A)
	if(isliving(A) && canClick()) UnarmedAttack(A)

/mob/living/simple_animal/hostile/scp682/get_status_tab_items()
	. = ..()
	if(stat == DEAD)
		var/time_left = max(0, round((respawn_time - (world.time - time_of_death)) / 600, 1))
		. += "Respawn in [time_left] min"
	else
		. += "AP: [round(ability_points)]/[max_ability_points]"
		if(in_acid)
			. += "Regen: ACTIVE"

/mob/living/simple_animal/hostile/scp682/movement_delay()
	. = ..()
	. -= round(damage_bonus * 0.02, 0.1)
