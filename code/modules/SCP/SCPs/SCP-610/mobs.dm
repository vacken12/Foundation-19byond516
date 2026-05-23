// ============================================================================
// SCP-610 - Infected mobs (Slasher, Leaper, Strider, Puker) with HUD
// ============================================================================

/proc/play_random_flesh_sound(atom/source, vol = 30)
	var/list/sounds = list(
		'sounds/scp/610/610_flesh.ogg',
		'sounds/scp/610/610_flesh_2.ogg',
		'sounds/scp/610/610_flesh_3.ogg',
		'sounds/scp/610/610_flesh_4.ogg',
		'sounds/scp/610/610_flesh_5.ogg'
	)
	playsound(source, pick(sounds), vol, 0, -2)

/proc/is_scp610_mob(mob/M)
	return (istype(M, /mob/living/simple_animal/hostile/scp610_slasher) || istype(M, /mob/living/simple_animal/hostile/scp610_leaper) || istype(M, /mob/living/simple_animal/hostile/scp610_strider) || istype(M, /mob/living/simple_animal/hostile/scp610_puker))

// ============================================================================
// BASE CLASS
// ============================================================================
/mob/living/simple_animal/hostile/scp610_base
	var/scp610_nest_cooldown = 60 SECONDS
	var/scp610_nest_cooldown_track = 0
	var/scp610_maw_cooldown = 60 SECONDS
	var/scp610_maw_cooldown_track = 0
	var/scp610_pillar_cooldown = 60 SECONDS
	var/scp610_pillar_cooldown_track = 0
	var/scp610_mend_cooldown = 60 SECONDS
	var/scp610_mend_cooldown_track = 0
	var/scp610_move_cooldown = 0
	var/scp610_ambient_cooldown = 0
	var/door_break_cooldown = 0

	default_pixel_x = 0
	default_pixel_y = 0
	attack_sound = 'sounds/scp/610/610_flesh_3.ogg'
	see_invisible = SEE_INVISIBLE_NOLIGHTING
	see_in_dark = 7
	hud_type = /datum/hud/scp610

/mob/living/simple_animal/hostile/scp610_base/Initialize(mapload)
	. = ..()
	pixel_x = default_pixel_x
	pixel_y = default_pixel_y
	add_language("Scarred Hivemind")
	default_language = all_languages["Scarred Hivemind"]

/mob/living/simple_animal/hostile/scp610_base/proc/scp610_do_life(ambient_prob, ambient_cd, ambient_vol)
	if(pixel_x != default_pixel_x || pixel_y != default_pixel_y)
		pixel_x = default_pixel_x
		pixel_y = default_pixel_y
	if((world.time - scp610_ambient_cooldown) >= ambient_cd && prob(ambient_prob))
		play_random_flesh_sound(src, ambient_vol)
		scp610_ambient_cooldown = world.time

/mob/living/simple_animal/hostile/scp610_base/proc/scp610_do_move_sound(move_prob, move_cd)
	if((world.time - scp610_move_cooldown) >= move_cd && prob(move_prob))
		play_random_flesh_sound(src, 15)
		scp610_move_cooldown = world.time

/mob/living/simple_animal/hostile/scp610_base/proc/scp610_do_death(death_infect_range, death_floor_range, death_floor_prob, death_gib_type)
	var/turf/T = get_turf(src)
	playsound(T, 'sounds/scp/610/610_flesh_2.ogg', 60, TRUE)
	for(var/mob/living/carbon/human/H in range(death_infect_range, T))
		if(!is_scp610_mob(H) && !H.SCP)
			H.infect_scp610()
	var/obj/structure/corruption/nest/N = new(T)
	for(var/turf/simulated/floor/F in range(1, T))
		if(istype(F, /turf/space)) continue
		if(locate(/obj/structure/corruption/weeds) in F) continue
		if(prob(death_floor_prob))
			new /obj/structure/corruption/weeds(F, N)
	new death_gib_type(T)

/mob/living/simple_animal/hostile/scp610_base/proc/do_place_nest()
	if((world.time - scp610_nest_cooldown_track) < scp610_nest_cooldown)
		to_chat(src, SPAN_WARNING("Flesh hive is not ready yet!"))
		return
	var/turf/T = get_step(src, src.dir)
	if(!T || T.density)
		to_chat(src, SPAN_WARNING("Not enough space in front of you!"))
		return
	visible_message(SPAN_DANGER("\The [src] tears a chunk of its own flesh and plants a writhing hive!"))
	adjustBruteLoss(10)
	new /obj/structure/corruption/nest(T)
	play_random_flesh_sound(src, 40)
	scp610_nest_cooldown_track = world.time

/mob/living/simple_animal/hostile/scp610_base/proc/do_place_maw()
	if((world.time - scp610_maw_cooldown_track) < scp610_maw_cooldown)
		to_chat(src, SPAN_WARNING("Maw is not ready yet!"))
		return
	var/turf/T = get_step(src, src.dir)
	if(!T || T.density)
		to_chat(src, SPAN_WARNING("Not enough space in front of you!"))
		return
	if(!(locate(/obj/structure/corruption/weeds) in T))
		to_chat(src, SPAN_WARNING("You can only place a maw on the flesh carpet!"))
		return
	visible_message(SPAN_DANGER("\The [src] vomits forth a gaping maw onto the flesh!"))
	adjustBruteLoss(15)
	new /obj/structure/corruption/maw(T)
	play_random_flesh_sound(src, 35)
	scp610_maw_cooldown_track = world.time

/mob/living/simple_animal/hostile/scp610_base/proc/do_place_pillar()
	if((world.time - scp610_pillar_cooldown_track) < scp610_pillar_cooldown)
		to_chat(src, SPAN_WARNING("Flesh pillar is not ready yet!"))
		return
	var/turf/T = get_step(src, src.dir)
	if(!T || T.density)
		to_chat(src, SPAN_WARNING("Not enough space in front of you!"))
		return
	if(!(locate(/obj/structure/corruption/weeds) in T) && !(locate(/obj/structure/corruption/nest) in T))
		to_chat(src, SPAN_WARNING("You can only place a pillar on the flesh carpet!"))
		return
	visible_message(SPAN_DANGER("\The [src] violently expels a pulsating pillar of flesh from its body!"))
	adjustBruteLoss(15)
	new /obj/structure/corruption/pillar(T)
	play_random_flesh_sound(src, 40)
	scp610_pillar_cooldown_track = world.time

/mob/living/simple_animal/hostile/scp610_base/proc/do_absorb()
	if(stat != CONSCIOUS) return
	var/atom/target = null
	if(ismob(pulling) && pulling in range(1, src))
		target = pulling
	else if(istype(pulling, /obj/item/scp610_fruit) && pulling in range(1, src))
		target = pulling
	else
		var/list/corpses = list()
		for(var/mob/living/carbon/human/H in range(1, src))
			if(H.stat == DEAD) corpses += H
		for(var/mob/living/simple_animal/hostile/scp610_base/M in range(1, src))
			if(M.stat == DEAD && M != src) corpses += M
		for(var/obj/item/scp610_fruit/F in range(1, src))
			corpses += F
		if(!length(corpses))
			to_chat(src, SPAN_WARNING("No corpses or fruit nearby. Try pulling something closer to absorb it."))
			return
		target = input(src, "Select something to absorb:", "Absorb") as null|anything in corpses
	if(!target || !Adjacent(target)) return
	visible_message(SPAN_DANGER("\The [src] begins absorbing [target] into its mass!"))
	if(!do_after(src, 5 SECONDS, target, bonus_percentage = 50)) return
	visible_message(SPAN_DANGER("\The [src] fully absorbs [target]!"))
	if(istype(target, /obj/item/scp610_fruit))
		adjustBruteLoss(-100)
		qdel(target)
	else if(isliving(target))
		var/mob/living/M = target
		M.ghostize()
		qdel(M)
		health = maxHealth
		heal_overall_damage(maxHealth, maxHealth)

/mob/living/simple_animal/hostile/scp610_base/proc/do_mend()
	var/turf/T = get_turf(src)
	if(!(locate(/obj/structure/corruption/weeds) in T) && !(locate(/obj/structure/corruption/nest) in T))
		to_chat(src, SPAN_WARNING("You must stand on the flesh carpet to mend yourself."))
		return
	if((world.time - scp610_mend_cooldown_track) < scp610_mend_cooldown)
		to_chat(src, SPAN_WARNING("You cannot mend yourself yet."))
		return
	visible_message(SPAN_NOTICE("\The [src] absorbs nutrients from the flesh carpet, knitting its wounds..."))
	if(!do_after(src, 3 SECONDS, T, bonus_percentage = 75)) return
	var/heal_amount = 20
	adjustBruteLoss(-heal_amount)
	to_chat(src, SPAN_NOTICE("You feel your wounds knitting together."))
	scp610_mend_cooldown_track = world.time

/mob/living/simple_animal/hostile/scp610_base/fire_act(exposed_temperature, exposed_volume)
	..()
	if(exposed_temperature > 400)
		adjustBruteLoss(Clamp((exposed_temperature - 400) / 5, 10, 60))

/mob/living/simple_animal/hostile/scp610_base/proc/do_hivemind()
	var/msg = input("Message to the hivemind:", "Hivemind") as text|null
	if(!msg) return
	say(msg, all_languages["Scarred Hivemind"])

// ============================================================================
// SLASHER - The Ripper
// ============================================================================
/mob/living/simple_animal/hostile/scp610_slasher
	parent_type = /mob/living/simple_animal/hostile/scp610_base
	name = "ripper"
	desc = "A reanimated corpse reshaped into a horrific form. Its blade arms are deadly."
	icon = 'icons/SCP/scp610/slasher.dmi'
	icon_state = "slasher"
	icon_living = "slasher"
	default_pixel_x = -8
	pixel_x = -8
	pixel_y = 0
	maxHealth = 150
	health = 150
	movement_cooldown = 4
	natural_weapon = /obj/item/natural_weapon/scp610_slasher_blades
	natural_armor = list(melee = ARMOR_MELEE_RESISTANT, bullet = ARMOR_BALLISTIC_PISTOL)

/mob/living/simple_animal/hostile/scp610_slasher/Initialize(mapload)
	. = ..()
	SCP = new /datum/scp(src, "ripper", SCP_KETER, "610-Slasher")

/mob/living/simple_animal/hostile/scp610_slasher/Life()
	. = ..()
	if(stat != DEAD)
		scp610_do_life(30, 8 SECONDS, 20)

/mob/living/simple_animal/hostile/scp610_slasher/Move()
	. = ..()
	if(.) scp610_do_move_sound(40, 4 SECONDS)

/mob/living/simple_animal/hostile/scp610_slasher/UnarmedAttack(atom/target)
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		if(!is_scp610_mob(H) && H.species?.name != "Scarred Creature")
			. = ..()
			if(prob(8))
				H.infect_scp610()
		return
	return ..()

/mob/living/simple_animal/hostile/scp610_slasher/death(gibbed)
	scp610_do_death(3, 3, 80, /obj/effect/gibspawner/generic)
	icon_state = "slasher_lying"
	icon_living = "slasher_lying"
	icon_dead = "slasher_lying"
	density = FALSE
	set_stat(DEAD)

/obj/item/natural_weapon/scp610_slasher_blades
	name = "blade arms"
	attack_verb = list("slashed", "ripped", "cleaved", "scythed")
	hitsound = 'sounds/scp/610/610_flesh_3.ogg'
	damtype = BRUTE
	force = 18
	edge = TRUE
	sharp = TRUE
	armor_penetration = 10

// ============================================================================
// LEAPER - The Stalker
// ============================================================================
/mob/living/simple_animal/hostile/scp610_leaper
	parent_type = /mob/living/simple_animal/hostile/scp610_base
	name = "stalker"
	desc = "A twisted creature with a bladed tail. It moves with unsettling, erratic motions."
	icon = 'icons/SCP/scp610/leaper.dmi'
	icon_state = "body"
	icon_living = "body"
	default_pixel_x = -16
	default_pixel_y = -24
	pixel_x = -16
	pixel_y = -24
	maxHealth = 250
	health = 250
	movement_cooldown = 3
	natural_weapon = /obj/item/natural_weapon/scp610_leaper_tail
	natural_armor = list(melee = ARMOR_MELEE_RESISTANT, bullet = ARMOR_BALLISTIC_PISTOL)
	var/leap_cooldown = 8 SECONDS
	var/leap_cooldown_track = 0
	var/leap_ready = FALSE

/mob/living/simple_animal/hostile/scp610_leaper/Initialize(mapload)
	. = ..()
	SCP = new /datum/scp(src, "stalker", SCP_KETER, "610-Leaper")

/mob/living/simple_animal/hostile/scp610_leaper/Life()
	. = ..()
	if(stat != DEAD)
		scp610_do_life(35, 6 SECONDS, 25)

/mob/living/simple_animal/hostile/scp610_leaper/Move()
	. = ..()
	if(.) scp610_do_move_sound(50, 3 SECONDS)

/mob/living/simple_animal/hostile/scp610_leaper/UnarmedAttack(atom/target)
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		if(!is_scp610_mob(H) && H.species?.name != "Scarred Creature")
			. = ..()
			if(prob(8))
				H.infect_scp610()
		return
	return ..()

/mob/living/simple_animal/hostile/scp610_leaper/ClickOn(atom/A)
	if(leap_ready)
		leap_ready = FALSE
		if((world.time - leap_cooldown_track) < leap_cooldown)
			to_chat(src, SPAN_WARNING("Not ready!"))
			return
		if(get_dist(src, A) > 6)
			to_chat(src, SPAN_WARNING("Too far!"))
			return
		var/turf/T = get_turf(A)
		if(!T || T.density || T.contains_dense_objects())
			to_chat(src, SPAN_WARNING("Can't leap there!"))
			return
		leap_cooldown_track = world.time
		visible_message(SPAN_DANGER("\The [src] leaps at [A]!"))
		playsound(get_turf(src), 'sounds/scp/610/610_flesh_5.ogg', 50, TRUE)
		forceMove(T)
		for(var/mob/living/carbon/human/H in range(1, T))
			if(H.stat == DEAD || is_scp610_mob(H) || H.species?.name == "Scarred Creature") continue
			H.Weaken(4)
			H.apply_damage(25, BRUTE)
			H.infect_scp610()
		return
	..()

/mob/living/simple_animal/hostile/scp610_leaper/death(gibbed)
	scp610_do_death(4, 4, 90, /obj/effect/gibspawner/human)
	icon_state = "body_lying"
	icon_living = "body_lying"
	icon_dead = "body_lying"
	density = FALSE
	set_stat(DEAD)

/obj/item/natural_weapon/scp610_leaper_tail
	name = "bladed tail"
	attack_verb = list("impaled", "gored", "skewered", "pierced")
	hitsound = 'sounds/scp/610/610_flesh_3.ogg'
	damtype = BRUTE
	force = 22
	edge = TRUE
	sharp = TRUE
	armor_penetration = 15

// ============================================================================
// STRIDER - The Crusher
// ============================================================================
/mob/living/simple_animal/hostile/scp610_strider
	parent_type = /mob/living/simple_animal/hostile/scp610_base
	name = "crusher"
	desc = "A towering, long-limbed brute. It moves with a lurching gait, smashing through anything in its path."
	icon = 'icons/SCP/scp610/strider.dmi'
	icon_state = "strider"
	icon_living = "strider"
	default_pixel_x = 0
	default_pixel_y = 0
	pixel_x = 0
	pixel_y = 0
	maxHealth = 300
	health = 300
	movement_cooldown = 5
	natural_weapon = /obj/item/natural_weapon/scp610_strider_fist
	natural_armor = list(melee = ARMOR_MELEE_RESISTANT, bullet = ARMOR_BALLISTIC_PISTOL)

/mob/living/simple_animal/hostile/scp610_strider/Initialize(mapload)
	. = ..()
	SCP = new /datum/scp(src, "crusher", SCP_KETER, "610-Strider")

/mob/living/simple_animal/hostile/scp610_strider/Life()
	. = ..()
	if(stat != DEAD)
		scp610_do_life(30, 9 SECONDS, 25)

/mob/living/simple_animal/hostile/scp610_strider/Move()
	. = ..()
	if(.) scp610_do_move_sound(40, 5 SECONDS)

/mob/living/simple_animal/hostile/scp610_strider/UnarmedAttack(atom/target)
	if(istype(target, /obj/machinery/door))
		var/obj/machinery/door/D = target
		if(D.density && (world.time >= door_break_cooldown))
			var/open_time = 5 SECONDS
			if(istype(D, /obj/machinery/door/blast))
				open_time = 8 SECONDS
			if(istype(D, /obj/machinery/door/airlock))
				var/obj/machinery/door/airlock/AR = D
				if(AR.locked)
					open_time += 2 SECONDS
				if(AR.welded)
					open_time += 2 SECONDS
			door_break_cooldown = world.time + open_time + 2 SECONDS
			visible_message(SPAN_WARNING("\The [src] begins prying open \the [D]..."))
			playsound(get_turf(src), 'sounds/machines/airlock_creaking.ogg', 50, TRUE)
			if(!do_after(src, open_time, D, bonus_percentage = 25))
				return
			if(istype(D, /obj/machinery/door/blast))
				var/obj/machinery/door/blast/DB = D
				DB.open(TRUE)
			else if(istype(D, /obj/machinery/door/airlock))
				var/obj/machinery/door/airlock/AR = D
				AR.unlock(TRUE)
				AR.welded = FALSE
				D.set_broken(TRUE)
				D.open(TRUE)
			else
				D.set_broken(TRUE)
				D.open(1)
			visible_message(SPAN_DANGER("\The [src] smashes through [D]!"))
		return
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		if(!is_scp610_mob(H) && H.species?.name != "Scarred Creature")
			. = ..()
			if(prob(8))
				H.infect_scp610()
		return
	return ..()

/mob/living/simple_animal/hostile/scp610_strider/death(gibbed)
	scp610_do_death(4, 4, 90, /obj/effect/gibspawner/human)
	icon_state = "strider_lying"
	icon_living = "strider_lying"
	icon_dead = "strider_lying"
	density = FALSE
	set_stat(DEAD)

/obj/item/natural_weapon/scp610_strider_fist
	name = "bony fist"
	attack_verb = list("bashed", "crushed", "smashed")
	hitsound = 'sounds/scp/610/610_flesh_3.ogg'
	damtype = BRUTE
	force = 12
	armor_penetration = 5

// ============================================================================
// PUKER - The Bile-Spitter (explodes on death)
// ============================================================================
/obj/item/natural_weapon/puker_claws
	name = "corroded claws"
	attack_verb = list("slashed", "burned", "melted")
	hitsound = 'sounds/scp/610/610_flesh_4.ogg'
	damtype = BURN
	force = 14
	edge = TRUE
	armor_penetration = 5

/mob/living/simple_animal/hostile/scp610_puker
	parent_type = /mob/living/simple_animal/hostile/scp610_base
	name = "bile-spitter"
	desc = "A bloated creature leaking corrosive fluids. It gurgles with barely contained bile."
	icon = 'icons/SCP/scp610/puker.dmi'
	icon_state = "puker"
	icon_living = "puker"
	default_pixel_x = -8
	pixel_x = -8
	pixel_y = 0
	maxHealth = 180
	health = 180
	movement_cooldown = 4
	natural_weapon = /obj/item/natural_weapon/puker_claws
	natural_armor = list(melee = ARMOR_MELEE_RESISTANT, bullet = ARMOR_BALLISTIC_PISTOL)
	var/snapshot_cooldown = 3 SECONDS
	var/snapshot_cooldown_track = 0
	var/puke_ready = FALSE

/mob/living/simple_animal/hostile/scp610_puker/Initialize(mapload)
	. = ..()
	SCP = new /datum/scp(src, "bile-spitter", SCP_KETER, "610-Puker")

/mob/living/simple_animal/hostile/scp610_puker/Life()
	. = ..()
	if(stat != DEAD)
		scp610_do_life(35, 7 SECONDS, 25)

/mob/living/simple_animal/hostile/scp610_puker/Move()
	. = ..()
	if(.) scp610_do_move_sound(45, 3 SECONDS)

/mob/living/simple_animal/hostile/scp610_puker/UnarmedAttack(atom/target)
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		if(!is_scp610_mob(H) && H.species?.name != "Scarred Creature")
			. = ..()
			if(prob(8))
				H.infect_scp610()
		return
	return ..()

/mob/living/simple_animal/hostile/scp610_puker/ClickOn(atom/A)
	if(puke_ready)
		puke_ready = FALSE
		if((world.time - snapshot_cooldown_track) < snapshot_cooldown)
			to_chat(src, SPAN_WARNING("Not ready!"))
			return
		snapshot_cooldown_track = world.time
		visible_message(SPAN_DANGER("\The [src] spits acid at [A]!"))
		playsound(get_turf(src), 'sounds/scp/610/610_flesh_4.ogg', 40, TRUE)
		var/obj/item/projectile/puker_snap/P = new(get_turf(src))
		P.firer = src
		P.original = A
		P.launch(A, src)
		return
	..()

/mob/living/simple_animal/hostile/scp610_puker/death(gibbed)
	visible_message(SPAN_DANGER("\The [src] bursts in a shower of gore and viscera!"))
	playsound(get_turf(src), 'sounds/scp/610/610_flesh_2.ogg', 60, TRUE)
	var/obj/effect/decal/cleanable/blood/gibs/G = new /obj/effect/decal/cleanable/blood/gibs(get_turf(src))
	G.basecolor = "#2d1a0a"
	G.update_icon()
	QDEL_IN(G, 5 MINUTES)
	new /obj/structure/corruption/nest(get_turf(src))
	qdel(src)

/obj/item/projectile/puker_snap
	name = "acid spit"
	icon = 'icons/SCP/scp610/puker_projectile.dmi'
	icon_state = "pukeshot"
	damage = 14
	damage_type = BURN
	speed = 0.5
	nodamage = FALSE

/obj/item/projectile/puker_snap/on_hit(atom/target)
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		H.apply_damage(damage, damage_type)
		H.infect_scp610()
		visible_message(SPAN_DANGER("[H] is splashed with acid!"))

// ============================================================================
// HUD WITH ABILITY BUTTONS
// ============================================================================
/datum/hud/scp610/New(mob/owner)
	mymob = owner
	..()

/datum/hud/scp610/instantiate()
	var/list/buttons = list(
		"Hivemind" = /atom/movable/screen/scp610/hivemind,
		"Infest"   = /atom/movable/screen/scp610/infest,
		"Absorb"   = /atom/movable/screen/scp610/absorb,
		"Mend"     = /atom/movable/screen/scp610/mend
	)
	if(istype(mymob, /mob/living/simple_animal/hostile/scp610_slasher) || istype(mymob, /mob/living/simple_animal/hostile/scp610_leaper))
		buttons["Maw"] = /atom/movable/screen/scp610/maw
	if(istype(mymob, /mob/living/simple_animal/hostile/scp610_strider))
		buttons["Construct"] = /atom/movable/screen/scp610/construct
	if(istype(mymob, /mob/living/simple_animal/hostile/scp610_puker))
		buttons["Puke"] = /atom/movable/screen/scp610/puke
	if(istype(mymob, /mob/living/simple_animal/hostile/scp610_leaper))
		buttons["Whip"] = /atom/movable/screen/scp610/whip

	var/pos = 1
	for(var/name in buttons)
		var/button_type = buttons[name]
		var/atom/movable/screen/scp610/btn = new button_type
		btn.screen_loc = "LEFT+[(pos-1)]:16,TOP-1"
		btn.name = name
		btn.hud = src
		mymob.client.screen += btn
		pos++

/atom/movable/screen/scp610
	icon = 'icons/SCP/scp610/Buttons.dmi'
	icon_state = "buttons"
	var/ability_name = ""
	var/datum/hud/scp610/hud = null

/atom/movable/screen/scp610/Initialize(mapload)
	. = ..()
	update_icon()

/atom/movable/screen/scp610/update_icon()
	cut_overlays()
	add_overlay(ability_name)

/atom/movable/screen/scp610/Click()
	if(!usr || usr.stat != CONSCIOUS || !hud?.mymob) return
	var/mob/living/simple_animal/hostile/scp610_base/M = hud.mymob
	if(!istype(M)) return

	switch(ability_name)
		if("hivemind") M.do_hivemind()
		if("infest") M.do_place_nest()
		if("maw") M.do_place_maw()
		if("construct") M.do_place_pillar()
		if("absorb") M.do_absorb()
		if("mend") M.do_mend()
		if("whip")
			var/mob/living/simple_animal/hostile/scp610_leaper/L = M
			if(istype(L))
				if((world.time - L.leap_cooldown_track) < L.leap_cooldown)
					to_chat(L, SPAN_WARNING("Leap is not ready yet!"))
					return
				L.leap_ready = TRUE
				to_chat(L, SPAN_DANGER("Click target within 6 tiles."))
		if("puke")
			var/mob/living/simple_animal/hostile/scp610_puker/P = M
			if(istype(P))
				if((world.time - P.snapshot_cooldown_track) < P.snapshot_cooldown)
					to_chat(P, SPAN_WARNING("Puke is not ready yet!"))
					return
				P.puke_ready = TRUE
				to_chat(P, SPAN_DANGER("Click target to fire."))

/atom/movable/screen/scp610/hivemind  { icon_state = "buttons"; ability_name = "hivemind" }
/atom/movable/screen/scp610/infest    { icon_state = "buttons"; ability_name = "infest" }
/atom/movable/screen/scp610/maw       { icon_state = "buttons"; ability_name = "maw" }
/atom/movable/screen/scp610/construct { icon_state = "buttons"; ability_name = "construct" }
/atom/movable/screen/scp610/absorb    { icon_state = "buttons"; ability_name = "absorb" }
/atom/movable/screen/scp610/mend      { icon_state = "buttons"; ability_name = "mend" }
/atom/movable/screen/scp610/puke      { icon_state = "buttons"; ability_name = "puke" }
/atom/movable/screen/scp610/whip      { icon_state = "buttons"; ability_name = "whip" }
