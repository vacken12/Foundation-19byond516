/obj/item/clothing/ring/scp714
	name = "jade ring"
	desc = "An ordinary green jade ring."
	icon = 'icons/SCP/scp-714.dmi'
	icon_state = "scp-714"
	item_icons = list(slot_gloves_str = 'icons/SCP/scp-714.dmi')
	item_state_slots = list(slot_gloves_str = "scp-ring_worn")


/obj/item/clothing/ring/scp714/Initialize()
	. = ..()
	SCP = new /datum/scp(
		src,
		"jade ring",
		SCP_SAFE,
		"714"
	)

/obj/item/clothing/ring/scp714/equipped(mob/user)
	if(user)
		var/mob/living/L = user
		L.ForceContractDisease(/datum/disease/advance/scp714, make_copy = FALSE, del_on_fail = TRUE)

/obj/item/clothing/ring/scp714/dropped(mob/user)
	if(user)
		var/mob/living/L = user
		for(var/datum/disease/advance/scp714/D in L.diseases)
			qdel(D)
	. = ..()

