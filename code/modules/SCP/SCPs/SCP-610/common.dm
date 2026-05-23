// ============================================================================
// SCP-610 - Common (language, corruption, bottle, disease, structures)
// ============================================================================

// Глобальный список z-уровней, где распространение запрещено
GLOBAL_LIST_INIT(scp610_no_spread_z, list(8))

// ============================================================================
// LANGUAGE
// ============================================================================

/datum/language/scarred_hivemind
	name = "Scarred Hivemind"
	desc = "A series of wet clicks, rasps, and guttural sounds shared by the flesh-infected."
	speech_verb = "rasps"
	ask_verb = "clicks"
	exclaim_verb = "shrieks"
	key = "h"
	flags = RESTRICTED | HIVEMIND
	shorthand = "FLESH"

// ============================================================================
// CORRUPTION WEEDS
// ============================================================================

/obj/structure/corruption/weeds
	name = "flesh carpet"
	desc = "A writhing, pulsating mat of infected tissue spreading across the floor."
	icon = 'icons/SCP/scp610/structure.dmi'
	icon_state = "corruption-1"
	density = FALSE
	anchored = TRUE
	layer = TURF_LAYER + 0.1
	var/health = 15
	var/max_health = 15
	var/obj/structure/corruption/nest/parent_nest
	var/dying = FALSE

/obj/structure/corruption/weeds/Initialize(mapload, obj/structure/corruption/nest/source_nest)
	. = ..()
	health = max_health
	icon_state = pick("corruption-1", "corruption-2", "corruption-3")
	if(z in GLOB.scp610_no_spread_z)
		return
	if(source_nest)
		parent_nest = source_nest
		LAZYADD(parent_nest.weed_list, src)
		if(parent_nest.phase == 1)
			addtimer(CALLBACK(src, PROC_REF(try_spread)), rand(15 SECONDS, 30 SECONDS))

/obj/structure/corruption/weeds/Destroy()
	if(parent_nest)
		LAZYREMOVE(parent_nest.weed_list, src)
		parent_nest = null
	return ..()

/obj/structure/corruption/weeds/proc/try_spread()
	if(QDELETED(src) || dying || !parent_nest)
		return
	if(parent_nest.phase != 1 || parent_nest.weed_list.len >= parent_nest.max_weeds)
		return
	var/dir = pick(GLOB.cardinal)
	var/turf/simulated/floor/T = get_step(src, dir)
	if(istype(T) && !locate(/obj/structure/corruption) in T)
		new /obj/structure/corruption/weeds(T, parent_nest)
	addtimer(CALLBACK(src, PROC_REF(try_spread)), rand(15 SECONDS, 30 SECONDS))

/obj/structure/corruption/weeds/attackby(obj/item/W, mob/user)
	user.setClickCooldown(CLICK_CD_ATTACK)
	visible_message(SPAN_DANGER("[user] strikes [src] with [W]!"))
	var/damage = W.force
	if(W.sharp)
		damage *= 1.5
	if(W.edge)
		damage *= 1.2
	health -= damage
	if(health <= 0)
		visible_message(SPAN_DANGER("[src] is destroyed!"))
		qdel(src)

/obj/structure/corruption/weeds/fire_act(exposed_temperature, exposed_volume)
	if(exposed_temperature > 400)
		visible_message(SPAN_DANGER("The flesh sizzles and burns away!"))
		qdel(src)

/obj/structure/corruption/weeds/proc/start_dying()
	if(dying)
		return
	dying = TRUE
	animate(src, alpha = 0, time = rand(3 SECONDS, 8 SECONDS))
	addtimer(CALLBACK(src, PROC_REF(do_qdel)), rand(3 SECONDS, 8 SECONDS))

/obj/structure/corruption/weeds/proc/do_qdel()
	qdel(src)

// ============================================================================
// CORRUPTION NEST
// ============================================================================

/obj/structure/corruption/nest
	name = "flesh hive"
	desc = "A towering, pulsating pillar of infected flesh, nurturing the corruption around it."
	icon = 'icons/SCP/scp610/structure.dmi'
	icon_state = "nest"
	density = TRUE
	anchored = TRUE
	layer = OBJ_LAYER
	var/health = 120
	var/max_health = 120
	var/list/weed_list = list()
	var/max_weeds = 24
	var/phase = 1

/obj/structure/corruption/nest/Initialize(mapload)
	. = ..()
	health = max_health
	if(z in GLOB.scp610_no_spread_z)
		return
	addtimer(CALLBACK(src, PROC_REF(spawn_initial_field)), 0.5 SECONDS)

/obj/structure/corruption/nest/proc/spawn_initial_field()
	var/turf/T = get_turf(src)
	for(var/turf/simulated/floor/F in range(1, T))
		if(F == T) continue
		if(istype(F, /turf/space)) continue
		if(!locate(/obj/structure/corruption/weeds) in F)
			spawn_weed(F)
	addtimer(CALLBACK(src, PROC_REF(start_expansion)), 2 SECONDS)

/obj/structure/corruption/nest/proc/start_expansion()
	if(QDELETED(src))
		return
	phase = 1
	addtimer(CALLBACK(src, PROC_REF(try_expand)), 30 SECONDS)

/obj/structure/corruption/nest/proc/try_expand()
	if(QDELETED(src) || phase != 1 || weed_list.len >= max_weeds)
		phase = 0
		return
	if(LAZYLEN(weed_list))
		var/obj/structure/corruption/weeds/W = pick(weed_list)
		if(!QDELETED(W))
			W.try_spread()
	addtimer(CALLBACK(src, PROC_REF(try_expand)), 30 SECONDS)

/obj/structure/corruption/nest/Destroy()
	for(var/obj/structure/corruption/weeds/W in weed_list)
		if(W && !QDELETED(W) && !W.dying)
			W.start_dying()
	weed_list.Cut()
	return ..()

/obj/structure/corruption/nest/proc/spawn_weed(turf/T)
	if(LAZYLEN(weed_list) >= max_weeds)
		return
	new /obj/structure/corruption/weeds(T, src)

/obj/structure/corruption/nest/attackby(obj/item/W, mob/user)
	user.setClickCooldown(CLICK_CD_ATTACK)
	visible_message(SPAN_DANGER("[user] strikes [src] with [W]!"))
	var/damage = W.force
	if(W.sharp)
		damage *= 1.5
	if(W.edge)
		damage *= 1.2
	health -= damage
	if(health <= 0)
		visible_message(SPAN_DANGER("[src] ruptures and collapses!"))
		playsound(get_turf(src), 'sounds/scp/610/610_flesh_2.ogg', 60, TRUE)
		qdel(src)

/obj/structure/corruption/nest/CanPass(atom/movable/mover, turf/target)
	return TRUE

/obj/structure/corruption/nest/fire_act(exposed_temperature, exposed_volume)
	if(exposed_temperature > 400)
		visible_message(SPAN_DANGER("[src] is rapidly consumed by flames!"))
		qdel(src)
	else
		health -= round(exposed_temperature / 30)
		if(health <= 0)
			visible_message(SPAN_DANGER("[src] collapses as it burns!"))
			qdel(src)

// ============================================================================
// CORRUPTION PILLAR
// ============================================================================

/obj/structure/corruption/pillar
	name = "flesh pillar"
	desc = "A pulsating pillar of corrupted flesh, rhythmically birthing grotesque fruit."
	icon = 'icons/SCP/scp610/structure.dmi'
	icon_state = "pillar"
	density = TRUE
	anchored = TRUE
	layer = OBJ_LAYER
	var/health = 150
	var/max_health = 150
	var/fruits_produced = 0
	var/max_fruits = 3
	var/fruit_cooldown = 80 SECONDS
	var/producing = FALSE

/obj/structure/corruption/pillar/Initialize(mapload)
	. = ..()
	health = max_health
	if(z in GLOB.scp610_no_spread_z)
		return
	addtimer(CALLBACK(src, PROC_REF(start_production)), 2 SECONDS)

/obj/structure/corruption/pillar/proc/start_production()
	if(QDELETED(src))
		return
	if(fruits_produced >= max_fruits)
		visible_message(SPAN_WARNING("[src] withers away after producing its last fruit."))
		qdel(src)
		return
	if(producing)
		return
	producing = TRUE
	flick("pillar_create", src)
	addtimer(CALLBACK(src, PROC_REF(spawn_fruit)), 2 SECONDS)

/obj/structure/corruption/pillar/proc/spawn_fruit()
	if(QDELETED(src))
		return
	var/turf/T = get_step(src, pick(GLOB.cardinal))
	if(!T || T.density)
		T = get_turf(src)
	new /obj/item/scp610_fruit(T)
	fruits_produced++
	producing = FALSE
	addtimer(CALLBACK(src, PROC_REF(start_production)), fruit_cooldown)

/obj/structure/corruption/pillar/attackby(obj/item/W, mob/user)
	user.setClickCooldown(CLICK_CD_ATTACK)
	visible_message(SPAN_DANGER("[user] strikes [src] with [W]!"))
	var/damage = W.force
	if(W.sharp)
		damage *= 1.5
	if(W.edge)
		damage *= 1.2
	health -= damage
	if(health <= 0)
		visible_message(SPAN_DANGER("[src] crumbles!"))
		playsound(get_turf(src), 'sounds/scp/610/610_flesh_2.ogg', 40, TRUE)
		qdel(src)

/obj/structure/corruption/pillar/fire_act(exposed_temperature, exposed_volume)
	if(exposed_temperature > 400)
		visible_message(SPAN_DANGER("[src] is rapidly consumed by flames!"))
		qdel(src)
	else
		health -= round(exposed_temperature / 30)
		if(health <= 0)
			visible_message(SPAN_DANGER("[src] collapses as it burns!"))
			qdel(src)

// ============================================================================
// CORRUPT FRUIT
// ============================================================================

/obj/item/scp610_fruit
	name = "pulsing fruit"
	desc = "A fleshy, tumor-like growth that pulses with a sickly warmth. It looks disturbingly appetizing."
	icon = 'icons/SCP/scp610/structure.dmi'
	icon_state = "fruit"
	w_class = ITEM_SIZE_SMALL

/obj/item/scp610_fruit/attack_self(mob/user)
	if(is_scp610_mob(user))
		user.visible_message(
			SPAN_NOTICE("[user] devours the fruit and rapidly regenerates!"),
			SPAN_NOTICE("You eat the fruit and feel your wounds heal at an incredible rate.")
		)
		playsound(user, 'sounds/scp/610/610_flesh_4.ogg', 30, TRUE)
		var/mob/living/simple_animal/hostile/scp610_base/M = user
		M.adjustBruteLoss(-100)
		qdel(src)
	else if(ishuman(user))
		var/mob/living/carbon/human/H = user
		H.visible_message(
			SPAN_DANGER("[H] eats the fruit. Their skin begins to shift unnaturally."),
			SPAN_DANGER("You eat the fruit. It tastes foul, and your body starts to burn!")
		)
		playsound(H, 'sounds/scp/610/610_flesh_4.ogg', 30, TRUE)
		H.infect_scp610()
		qdel(src)
	else
		..()

// ============================================================================
// CORRUPTION MAW
// ============================================================================

/obj/structure/corruption/maw
	name = "gaping maw"
	desc = "A tooth-lined orifice in the floor, snapping at anything that wanders too close."
	icon = 'icons/SCP/scp610/structure.dmi'
	icon_state = "maw"
	density = FALSE
	anchored = TRUE
	layer = OBJ_LAYER - 0.1
	var/trap_cooldown = 10 SECONDS
	var/list/trapped_mobs = list()

/obj/structure/corruption/maw/Initialize(mapload)
	. = ..()
	playsound(get_turf(src), 'sounds/scp/610/610_flesh_4.ogg', 40, TRUE)

/obj/structure/corruption/maw/Crossed(atom/movable/AM)
	if(ishuman(AM))
		var/mob/living/carbon/human/H = AM
		if(H in trapped_mobs || H.lying || is_scp610_mob(H) || H.species?.name == "Scarred Creature" || H.SCP)
			return
		H.visible_message(
			SPAN_DANGER("[H] is caught by the maw!"),
			SPAN_DANGER("A maw snaps shut around your leg!")
		)
		playsound(get_turf(src), 'sounds/scp/610/610_flesh_2.ogg', 50, TRUE)
		H.Weaken(5)
		H.apply_damage(20, BRUTE)
		H.infect_scp610()
		trapped_mobs += H
		addtimer(CALLBACK(src, PROC_REF(release_mob), H), trap_cooldown)

/obj/structure/corruption/maw/proc/release_mob(mob/living/carbon/human/H)
	if(H && !QDELETED(H))
		trapped_mobs -= H

/obj/structure/corruption/maw/attackby(obj/item/W, mob/user)
	if(W.sharp && W.force >= 10)
		visible_message(SPAN_DANGER("[user] cuts through [src], destroying it!"))
		playsound(get_turf(src), 'sounds/scp/610/610_flesh_2.ogg', 40, TRUE)
		qdel(src)
		return
	..()

/obj/structure/corruption/maw/fire_act(exposed_temperature, exposed_volume)
	visible_message(SPAN_DANGER("[src] sizzles and burns away!"))
	qdel(src)

// ============================================================================
// BOTTLE
// ============================================================================

/obj/item/reagent_containers/glass/bottle/scp610
	name = "corruption sample"
	desc = "A sealed container holding a pulsating mass of corruption."
	icon = 'icons/SCP/scp610/structure.dmi'
	icon_state = "610_sample"

/obj/item/reagent_containers/glass/bottle/scp610/attack_self(mob/user)
	if(alert(user, "Opening this will release corruption and may infect you and those nearby. Continue?", "Corruption Sample", "Yes", "No") != "Yes")
		return
	user.visible_message(
		SPAN_DANGER("[user] uncorks the bottle, releasing a foul stench!"),
		SPAN_DANGER("You open the bottle. The corruption spills out!")
	)
	for(var/mob/living/carbon/human/H in range(2, user))
		H.infect_scp610()
	playsound(get_turf(user), 'sounds/scp/610/610_flesh.ogg', 30, TRUE)
	qdel(src)

/obj/item/reagent_containers/glass/bottle/scp610/afterattack(atom/target, mob/user, proximity_flag)
	if(!proximity_flag)
		return
	if(ishuman(target))
		if(alert(user, "Smash the bottle against [target]? This will infect them and those nearby.", "Corruption Sample", "Yes", "No") != "Yes")
			return
		var/mob/living/carbon/human/H = target
		H.infect_scp610()
		for(var/mob/living/carbon/human/V in range(1, H))
			V.infect_scp610()
		playsound(get_turf(H), 'sounds/scp/610/610_flesh.ogg', 50, TRUE)
		qdel(src)
		return
	if(istype(target, /turf/simulated/floor))
		if(alert(user, "Smash the bottle on the floor? This will spread corruption.", "Corruption Sample", "Yes", "No") != "Yes")
			return
		var/turf/simulated/floor/F = target
		new /obj/structure/corruption/nest(F)
		playsound(get_turf(target), 'sounds/scp/610/610_flesh.ogg', 50, TRUE)
		qdel(src)
		return
	..()

// ============================================================================
// DISEASE
// ============================================================================

/datum/disease/scp610
	name = "Corruption Infection"
	form = "Necrotic Corruption"
	max_stages = 3
	spread_text = "Physical contact, contaminated surfaces"
	spread_flags = DISEASE_SPREAD_BLOOD | DISEASE_SPREAD_CONTACT_SKIN | DISEASE_SPREAD_CONTACT_FLUIDS
	cure_text = "Amputation of affected limb in early stages; incineration of late-stage victims"
	cures = list()
	agent = "corruption mutagen"
	viable_mobtypes = list(/mob/living/carbon/human)
	desc = "A slowly spreading infection. Causes severe scarring and eventual transformation."
	severity = DISEASE_SEVERITY_DANGEROUS
	permeability_mod = 1
	bypasses_immunity = TRUE

/datum/disease/scp610/StageAct()
	. = ..()
	if(!.)
		return
	var/mob/living/carbon/human/H = affected_mob
	if(!istype(H))
		return
	if(H.SCP)
		return

	if(H.on_fire)
		H.adjustBruteLoss(3)
		H.Weaken(2)
		to_chat(H, SPAN_DANGER("<b>The fire accelerates the corruption! Your body is reshaping!</b>"))
		H.visible_message(SPAN_DANGER("[H]'s flesh writhes and twists in the flames!"))
		if(stage < 3)
			stage = 3
			to_chat(H, SPAN_DANGER("<b>The infection surges through your burning body!</b>"))
		spawn(10 SECONDS)
			if(H && H.on_fire && H.stat != DEAD)
				complete_transformation(H)
		return

	switch(stage)
		if(1)
			if(prob(8))
				to_chat(H, SPAN_WARNING("Your skin feels slightly irritated."))
			if(prob(3))
				H.adjustToxLoss(0.3)
				to_chat(H, SPAN_WARNING("A faint rash appears on your skin."))

		if(2)
			if(prob(10))
				var/part = pick(list("chest", "arms", "legs", "face", "back", "hands"))
				to_chat(H, SPAN_DANGER("Scar-like marks cover your [part]."))
				H.adjustBruteLoss(1)
			if(prob(5))
				H.Weaken(3)
				to_chat(H, SPAN_DANGER("Your muscles twitch painfully."))

		if(3)
			H.visible_message(SPAN_DANGER("<b>[H.name]</b> collapses, body convulsing violently!"))
			H.Stun(12)
			H.adjustBruteLoss(18)
			spawn(300)
				if(H && H.stat != DEAD)
					complete_transformation(H)

/datum/disease/scp610/proc/complete_transformation(mob/living/carbon/human/H)
	var/transform_type = pickweight(list(
		"slasher" = 25,
		"puker" = 25,
		"leaper" = 25,
		"strider" = 25
	))
	var/mob/living/simple_animal/hostile/new_mob
	switch(transform_type)
		if("slasher")
			H.visible_message(SPAN_DANGER("<b>[H.name] twists into a slasher!</b>"))
			new_mob = new /mob/living/simple_animal/hostile/scp610_slasher(get_turf(H))
		if("leaper")
			H.visible_message(SPAN_DANGER("<b>[H.name] mutates into a leaper!</b>"))
			new_mob = new /mob/living/simple_animal/hostile/scp610_leaper(get_turf(H))
		if("strider")
			H.visible_message(SPAN_DANGER("<b>[H.name] elongates into a strider!</b>"))
			new_mob = new /mob/living/simple_animal/hostile/scp610_strider(get_turf(H))
		if("puker")
			H.visible_message(SPAN_DANGER("<b>[H.name] bloats into a puker!</b>"))
			new_mob = new /mob/living/simple_animal/hostile/scp610_puker(get_turf(H))
	if(new_mob && H.mind)
		H.mind.transfer_to(new_mob)
	playsound(get_turf(H), 'sounds/scp/610/610_flesh_5.ogg', 60, TRUE)
	qdel(H)

/mob/living/carbon/human/proc/infect_scp610()
	set name = "Infect SCP-610"
	set hidden = TRUE
	for(var/datum/disease/scp610/D in diseases)
		return FALSE
	if(SCP)
		return FALSE
	var/datum/disease/scp610/D = new()
	D.Infect(src, FALSE)
	playsound(get_turf(src), 'sounds/scp/610/610_flesh_4.ogg', 30, TRUE)
	visible_message(SPAN_DANGER("[src] comes into contact with corruption!"))
	to_chat(src, SPAN_WARNING("You feel something foreign against your skin..."))
	return TRUE
