/obj/machinery/scp330
	name = "bowl of sweets"
	desc = "A bowl with colorful candies of an unknown brand. Taped to the edge of the bowl is a handwritten note: Dont take more than two, please! "

	icon = 'icons/SCP/scp-330.dmi'
	icon_state = "scp-330"

	anchored = TRUE
	density = FALSE

	var/list/user_takes = list()

/obj/machinery/scp330/Initialize()
	. = ..()
	SCP = new /datum/scp(
		src,
		"bowl of sweets",
		SCP_SAFE,
		"330",
	)

/obj/machinery/scp330/attack_hand(mob/user)
	. = ..()
	if(!istype(user, /mob/living/carbon/human))
		return

	var/mob/living/carbon/H = user

	if(!user_takes[H.ckey])
		user_takes[H.ckey] = 0

	user_takes[H.ckey] += 1
	var/user_candies_taken = user_takes[H.ckey]

	var/candy_type
	switch(rand(1,6))
		if(1)	candy_type = /obj/item/reagent_containers/food/snacks/scp330/candy_red
		if(2)	candy_type = /obj/item/reagent_containers/food/snacks/scp330/candy_yellow
		if(3)	candy_type = /obj/item/reagent_containers/food/snacks/scp330/candy_green
		if(4)	candy_type = /obj/item/reagent_containers/food/snacks/scp330/candy_purple
		if(5)	candy_type = /obj/item/reagent_containers/food/snacks/scp330/candy_pink
		if(6)	candy_type = /obj/item/reagent_containers/food/snacks/scp330/candy_rainbow

	var/obj/item/I = new candy_type
	H.put_in_active_hand(I)

	if(user_candies_taken >= 3)
		amputate(H)

/obj/machinery/scp330/proc/amputate(mob/living/carbon/human/target)
	if(!istype(target) || QDELETED(target) || !target.client)
		return

	playsound(src, "bone_break", 75, TRUE)
	if(!target.incapacitated())
		target.emote("scream")

	target.visible_message(SPAN_WARNING("[target]'s hands fall to the floor with a terrible sound!"), \
	SPAN_WARNING("Your hands fall to the floor with a terrible sound!"))

	var/obj/item/organ/external/left_hand = target.get_organ(BP_L_HAND)
	var/obj/item/organ/external/right_hand = target.get_organ(BP_R_HAND)

	if(left_hand)
		left_hand.droplimb(TRUE, DROPLIMB_EDGE)
	if(right_hand)
		right_hand.droplimb(TRUE, DROPLIMB_EDGE)

	target.update_body()
	target.shock_stage = max(target.shock_stage, 3)

/obj/item/reagent_containers/food/snacks/scp330/candy_red
	name = "red candy"
	desc = "Just a delicious candy."
	icon = 'icons/SCP/scp-330.dmi'
	icon_state = "candy_red"
	nutriment_desc = list("candy" = 1)
	nutriment_amt = 2
	bitesize = 20
	food_reagents = list(
	/datum/reagent/nutriment/protein = 2,
	/datum/reagent/medicine/bicaridine = 6,
	/datum/reagent/medicine/kelotane = 6
	)

/obj/item/reagent_containers/food/snacks/scp330/candy_yellow
	name = "yellow candy"
	desc = "Just a delicious candy."
	icon = 'icons/SCP/scp-330.dmi'
	icon_state = "candy_yellow"
	nutriment_desc = list("candy" = 1)
	nutriment_amt = 2
	bitesize = 20
	food_reagents = list(
	/datum/reagent/nutriment/protein = 2,
	/datum/reagent/medicine/stimulant/hyperzine = 10
	)

/obj/item/reagent_containers/food/snacks/scp330/candy_yellow/On_Consume(mob/user)
	..()
	user.set_light(1, 1, 4, l_color = "#FFFF00")
	spawn(300)
		if(user)
			user.set_light(0)

/obj/item/reagent_containers/food/snacks/scp330/candy_green
	name = "green candy"
	desc = "Just a delicious candy."
	icon = 'icons/SCP/scp-330.dmi'
	icon_state = "candy_green"
	nutriment_desc = list("candy" = 1)
	nutriment_amt = 2
	bitesize = 20
	food_reagents = list(
	/datum/reagent/nutriment/protein = 2,
	/datum/reagent/medicine/painkiller/tramadol = 5,
	/datum/reagent/medicine/dylovene = 5,
	/datum/reagent/random = 5
	)

/obj/item/reagent_containers/food/snacks/scp330/candy_purple
	name = "purple candy"
	desc = "Just a delicious candy."
	icon = 'icons/SCP/scp-330.dmi'
	icon_state = "candy_purple"
	nutriment_desc = list("candy" = 1)
	nutriment_amt = 2
	bitesize = 20
	food_reagents = list(
	/datum/reagent/nutriment/protein = 2
	)

/obj/item/reagent_containers/food/snacks/scp330/candy_purple/On_Consume(mob/user)
	..()
	to_chat(user, SPAN_NOTICE("You feel your perception shifting..."))
	for(var/i = 1 to 5)
		var/turf/T = get_turf(user)
		var/list/possible_turfs = list()
		for(var/turf/turf in range(15, T))
			if(turf && !isspaceturf(turf) && !turf.density)
				possible_turfs += turf
		if(length(possible_turfs))
			var/turf/destination = pick(possible_turfs)
			user.forceMove(destination)
			playsound(user, 'sounds/effects/phasein.ogg', 50, TRUE)
			sparks(5, FALSE, user)
			sleep(20)

/obj/item/reagent_containers/food/snacks/scp330/candy_pink
	name = "pink candy"
	desc = "Just a delicious candy."
	icon = 'icons/SCP/scp-330.dmi'
	icon_state = "candy_pink"
	nutriment_desc = list("candy" = 1)
	nutriment_amt = 2
	bitesize = 20
	food_reagents = list(
	/datum/reagent/nutriment/protein = 2
	)

/obj/item/reagent_containers/food/snacks/scp330/candy_pink/On_Consume(mob/user)
	..()
	to_chat(user, SPAN_DANGER("The candy explodes from inside you!"))
	visible_message(SPAN_DANGER("[user] explodes in a shower of gore!"))
	explosion(get_turf(user), 0, 1, 2, 3)
	user.gib()

/obj/item/reagent_containers/food/snacks/scp330/candy_rainbow
	name = "rainbow candy"
	desc = "Rainbow candy! Wow!"
	icon = 'icons/SCP/scp-330.dmi'
	icon_state = "candy_rainbow"
	nutriment_desc = list("candy" = 1)
	nutriment_amt = 2
	bitesize = 20
	food_reagents = list(
	/datum/reagent/nutriment/protein = 2,
	/datum/reagent/medicine/tricordrazine = 4,
	/datum/reagent/medicine/stimulant/hyperzine = 4,
	/datum/reagent/medicine/painkiller/tramadol = 4,
	/datum/reagent/psilocybin = 4
	)
