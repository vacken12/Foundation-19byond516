/obj/item/clothing/mask/scp1499
	name = "gas mask"
	desc = "An old soviet GP-5 gas mask."
	icon = 'icons/SCP/scp-1499.dmi'
	icon_state = "scp-1499"
	body_parts_covered = FACE
	w_class = ITEM_SIZE_SMALL
	item_icons = list(slot_wear_mask_str = 'icons/SCP/scp-1499.dmi')
	item_state_slots = list(slot_wear_mask_str = "scp-1499_worn")
	overlay = /atom/movable/screen/fullscreen/protivogaz

	/// How long after putting on the mask before the wearer is transported
	var/wear_time = 3 SECONDS
	/// Area type of the pocket dimension to look for
	var/pocket_dimension_area_type = /area/scp/dimension004/scp1499
	/// Cooldown between pocket dimension transitions
	var/pocket_dimension_cooldown_time = 20 SECONDS
	/// Pocket dimension cooldown tracker
	var/pocket_dimension_cooldown
	/// Last known coordinates of the wearer before entering the pocket dimension
	var/last_x = -1
	var/last_y = -1
	var/last_z = -1
	/// If TRUE, bypasses the cooldown and incapacitation checks
	var/forced = FALSE
	/// Whether the wearer is currently inside the pocket dimension
	var/in_pocket_dimension = FALSE

/obj/item/clothing/mask/scp1499/Initialize()
	. = ..()
	SCP = new /datum/scp(src, "gas mask", SCP_SAFE, "1499")

/obj/item/clothing/mask/scp1499/Destroy()
	STOP_PROCESSING(SSobj, src)
	update_vision()
	return ..()

/obj/item/clothing/mask/scp1499/needs_vision_update()
	return ..() || overlay

/obj/item/clothing/mask/scp1499/equipped(mob/user, slot)
	. = ..()
	if(slot != slot_wear_mask)
		return
	user.visible_message(SPAN_NOTICE("\The [user] puts on \the [src]."))
	update_vision()
	var/datum/callback/worn_check = CALLBACK(src, TYPE_PROC_REF(/obj/item/clothing/mask/scp1499, mask_is_worn), user)
	if(do_after(user, wear_time, user, extra_checks = worn_check))
		to_dimension(user)
		update_vision()

/obj/item/clothing/mask/scp1499/dropped(mob/user)
	if(in_pocket_dimension && user && last_x != -1)
		var/datum/callback/removed_check = CALLBACK(src, TYPE_PROC_REF(/obj/item/clothing/mask/scp1499, mask_is_removed), user)
		if(do_after(user, wear_time, user, extra_checks = removed_check))
			to_return(user)
			update_vision()
	. = ..()

/obj/item/clothing/mask/scp1499/proc/mask_is_worn(mob/user)
	return istype(user) && user.get_equipped_item(slot_wear_mask) == src

/obj/item/clothing/mask/scp1499/proc/mask_is_removed(mob/user)
	return istype(user) && user.get_equipped_item(slot_wear_mask) != src

/obj/item/clothing/mask/scp1499/proc/to_dimension(mob/living/user)
	if(!istype(user) || user.get_equipped_item(slot_wear_mask) != src)
		return FALSE

	if(!forced)
		if(pocket_dimension_cooldown > world.time)
			to_chat(user, SPAN_WARNING("You are not ready to enter the pocket dimension just yet."))
			return FALSE
		if(user.incapacitated())
			return FALSE
		pocket_dimension_cooldown = world.time + 50

	var/turf/T = pick_area_turf(pocket_dimension_area_type, list(GLOBAL_PROC_REF(not_turf_contains_dense_objects)))
	if(!istype(T))
		return FALSE

	pocket_dimension_cooldown = world.time + pocket_dimension_cooldown_time
	animate(user, alpha = 0, time = 5)
	set_last_xyz(user)
	sleep(2) // Le cool visual effects
	animate(user, alpha = 255, time = 5,)
	user.forceMove(T)
	in_pocket_dimension = TRUE
	update_vision()
	return TRUE

/obj/item/clothing/mask/scp1499/proc/to_return(mob/living/user)
	if(!istype(user))
		return FALSE

	if(last_x != -1) // shouldn't be possible but just in case
		user.alpha = 0
		user.forceMove(locate(last_x, last_y, last_z))
		user.stunned = 1
		animate(user, alpha = 255, time = 5)
	in_pocket_dimension = FALSE
	update_vision()
	return TRUE

/obj/item/clothing/mask/scp1499/proc/set_last_xyz(mob/living/user)
	last_x = user.x
	last_y = user.y
	last_z = user.z



					// MOB
/mob/living/simple_animal/hostile/scp1499_1
	name = "creature"
	desc = "A sanity-destroying otherthing."

	icon = 'icons/SCP/scp-1499.dmi'
	icon_state = "scp-1499-1"
	icon_living = "scp-1499-1"
	icon_dead = "scp-1499-1"

	speak_emote = list("gibbers")

	health = 200
	maxHealth = 200
	natural_weapon = /obj/item/natural_weapon/claws/strong
	melee_attack_delay = 1 SECOND
	faction = "creature"
	movement_cooldown = 4
	supernatural = 1

	var/mob_count = 0
	var/icon_states_pick = null

/mob/living/simple_animal/hostile/scp1499_1/Initialize()
	. = ..()
	set_light(0.5, 0.1, 2)

	mob_count++
	SCP = new /datum/scp(src, "creature", SCP_SAFE, "1499-[mob_count]")

	icon_states_pick = pick("scp-1499-1", "scp-1499-2")

	icon_state = icon_states_pick
	icon_living = icon_states_pick
	icon_dead = icon_states_pick



/obj/effect/projectile/invislight/scp1499
	light_max_bright = 0.15
	light_inner_range = 1
	light_outer_range = 6
	light_color = "#ff9102"
