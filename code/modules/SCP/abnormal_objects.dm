// -----------------------------------------------------------------------------
// Diamond Brick
// -----------------------------------------------------------------------------
/obj/item/material/diamond_brick
    name = "anomalous diamond"
    desc = "A diamond shaped like an inverted cone. It occasionally emits a faint pulse of light."
    icon = 'icons/SCP/abnormal_objects.dmi'
    icon_state = "gem"
    default_material = MATERIAL_DIAMOND
    applies_material_name = 0
    max_force = 10
    force_multiplier = 0.3
    thrown_force_multiplier = 0.5
    w_class = ITEM_SIZE_NORMAL
    attack_verb = list("bashed", "crushed")

    var/list/gem_animations = list("gem_1", "gem_2", "gem_3")

/obj/item/material/diamond_brick/Initialize()
    . = ..()
    schedule_animation()

/obj/item/material/diamond_brick/proc/schedule_animation()
    if(QDELETED(src)) return
    addtimer(CALLBACK(src, PROC_REF(play_animation)), rand(30, 120) SECONDS)

/obj/item/material/diamond_brick/proc/play_animation()
    if(QDELETED(src)) return
    var/chosen = pick(gem_animations)
    flick(chosen, src)
    schedule_animation()

// -----------------------------------------------------------------------------
// Spear of Betrayal
// -----------------------------------------------------------------------------
/obj/item/melee/spear_of_betrayal
	name = "ancient spear"
	desc = "An old spear. The shaft bears an inscription in an unknown language."
	icon = 'icons/SCP/abnormal_objects.dmi'
	icon_state = "military_spear"
	item_state = "military_spear"
	item_icons = list(
		slot_l_hand_str = 'icons/mob/onmob/items/lefthand.dmi',
		slot_r_hand_str = 'icons/mob/onmob/items/righthand.dmi'
	)
	force = 10
	throwforce = 20
	w_class = ITEM_SIZE_HUGE
	attack_verb = list("stabbed", "pierced")
	var/mob/living/thrower = null

/obj/item/melee/spear_of_betrayal/throw_at(atom/target, range, speed, mob/thrower, spin, diagonals_first, datum/callback/callback, gentle)
	src.thrower = thrower
	. = ..()

/obj/item/melee/spear_of_betrayal/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	if(thrower && isliving(thrower) && thrower.stat != DEAD)
		thrower.visible_message(
			SPAN_DANGER("[src] twists mid-air and plunges into [thrower]'s chest!"),
			SPAN_DANGER("[src] wrenches from your hand and pierces your heart!")
		)
		thrower.apply_damage(100, BRUTE, BP_CHEST)
		thrower.emote("scream")
		src.forceMove(get_turf(thrower))
	else
		. = ..()
	src.thrower = null

// -----------------------------------------------------------------------------
// Compulsive Cowboy Hat
// -----------------------------------------------------------------------------
/obj/item/clothing/head/cowboy_compulsive
	name = "white cowboy hat"
	desc = "A pristine white cowboy hat. It fills you with an inexplicable urge to dance."
	icon = 'icons/SCP/abnormal_objects.dmi'
	icon_state = "compulsive"
	body_parts_covered = 0
	var/last_yeehaw = 0
	var/going_up = TRUE

/obj/item/clothing/head/cowboy_compulsive/equipped(mob/living/carbon/human/user, slot)
	. = ..()
	if(slot == slot_head)
		user.visible_message(SPAN_NOTICE("[user] puts on [src] and starts bouncing!"))
		START_PROCESSING(SSprocessing, src)

/obj/item/clothing/head/cowboy_compulsive/dropped(mob/living/carbon/human/user)
	STOP_PROCESSING(SSprocessing, src)
	user.pixel_y = 0
	. = ..()

/obj/item/clothing/head/cowboy_compulsive/Process()
	var/mob/living/carbon/human/M = loc
	if(!istype(M) || M.head != src || M.stat == DEAD)
		STOP_PROCESSING(SSprocessing, src)
		return

	if(going_up)
		M.pixel_y = 4
		going_up = FALSE
	else
		M.pixel_y = 0
		going_up = TRUE

	if(world.time >= last_yeehaw + 15 SECONDS)
		last_yeehaw = world.time
		M.audible_message(SPAN_NOTICE("[M] bounces around, yeehawing!"))
		playsound(get_turf(M), 'sounds/voice/yeehaw.ogg', 50, 0)

	sleep(0.3)

// -----------------------------------------------------------------------------
// Marshmallow Blue Flame
// -----------------------------------------------------------------------------
/obj/item/reagent_containers/food/snacks/marshmallow_blue_flame
	name = "marshmallow"
	desc = "A pack of marshmallows that radiate a faint warmth."
	icon = 'icons/SCP/abnormal_objects.dmi'
	icon_state = "marshmallow"
	bitesize = 10
	nutriment_amt = 2
	nutriment_desc = list("sugar" = 2)

/obj/item/reagent_containers/food/snacks/marshmallow_blue_flame/Initialize()
	. = ..()
	reagents.add_reagent(/datum/reagent/sugar, 4)

/obj/item/reagent_containers/food/snacks/marshmallow_blue_flame/On_Consume(mob/M)
	. = ..()
	if(ishuman(M))
		M.visible_message(SPAN_DANGER("[M]'s head is engulfed in a ring of cold blue flame!"))
		spawn(0)
			var/obj/effect/blue_flame/BF = new(get_turf(M))
			BF.attach_to(M)
			QDEL_IN(BF, 20 SECONDS)

/obj/effect/blue_flame
	name = "blue flame"
	icon = 'icons/SCP/abnormal_objects.dmi'
	icon_state = "fire"
	anchored = TRUE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	layer = ABOVE_HUMAN_LAYER + 1
	plane = EFFECTS_ABOVE_LIGHTING_PLANE
	pixel_y = 6
	var/mob/living/following

/obj/effect/blue_flame/proc/attach_to(mob/living/M)
	following = M
	forceMove(get_turf(M))
	RegisterSignal(M, COMSIG_MOVED, TYPE_PROC_REF(/atom/movable, move_to_loc_or_null))

/obj/effect/blue_flame/Destroy()
	if(following)
		UnregisterSignal(following, COMSIG_MOVED)
		following = null
	. = ..()

// -----------------------------------------------------------------------------
// Gelatin Skull
// -----------------------------------------------------------------------------
/obj/item/gelatin_skull
	name = "gelatin skull"
	desc = "A replica of a human skull made entirely of gelatin."
	icon = 'icons/SCP/abnormal_objects.dmi'
	icon_state = "skull"
	w_class = ITEM_SIZE_TINY
	var/sound_played = FALSE

/obj/item/gelatin_skull/Initialize(mapload)
	. = ..()
	var/random_delay = rand(6000, 18000)
	addtimer(CALLBACK(src, PROC_REF(play_skull_music)), random_delay)

/obj/item/gelatin_skull/proc/play_skull_music()
	if(sound_played || QDELETED(src))
		return
	sound_played = TRUE
	playsound(src, 'sounds/music/TwinTribesShadows.ogg', 100, 0, 7, 50)
	visible_message(SPAN_NOTICE("[src] begins to play an eerie melody."))

// -----------------------------------------------------------------------------
// Pizza Ritual Receipt
// -----------------------------------------------------------------------------
/obj/item/pizza_ritual
	name = "receipt"
	desc = "An old pizzeria receipt. Faint symbols are visible on the back, along with a barely legible note: \"Light a candle. Place it near the vessel. Speak the words.\""
	icon = 'icons/SCP/abnormal_objects.dmi'
	icon_state = "ticket"
	item_state = "ticket"
	w_class = ITEM_SIZE_TINY
	var/ritual_in_progress = FALSE

/obj/item/pizza_ritual/examine(mob/user, distance, infix, suffix)
	. = ..()
	. += SPAN_NOTICE("\"Light a candle. Place it near the vessel. Speak the words.\"")

/obj/item/pizza_ritual/attack_self(mob/user)
	if(ritual_in_progress)
		return

	var/mob/living/carbon/human/corpse = locate() in range(1, user)
	if(!corpse || corpse.stat != DEAD)
		to_chat(user, SPAN_WARNING("There is no suitable vessel nearby."))
		return

	var/obj/item/flame/candle = locate() in range(1, corpse)
	if(!candle || !candle.lit)
		to_chat(user, SPAN_WARNING("A lit candle must be placed near the vessel."))
		return

	ritual_in_progress = TRUE
	user.visible_message(
		SPAN_DANGER("[user] raises [src] and begins chanting in an unknown tongue!"),
		SPAN_DANGER("You feel an otherworldly presence...")
	)

	var/static/list/chant_lines = list(
		"Klaatu... barada... nikto...",
		"Pizza... pepperoni... extra cheese...",
		"From beyond the veil, I call thee forth!",
		"DELIVERY!"
	)

	for(var/line in chant_lines)
		if(!user.Adjacent(corpse) || user.stat != CONSCIOUS || user.get_active_hand() != src)
			ritual_in_progress = FALSE
			return
		user.say(line)
		sleep(15)

	playsound(corpse, 'sounds/magic/castsummon.ogg', 60, 1)
	user.visible_message(
		SPAN_DANGER("[corpse] is consumed by a blinding light, leaving behind a steaming pizza box!"),
		SPAN_DANGER("The vessel is consumed! The pact is complete!")
	)
	new /obj/item/pizzabox/meat(get_turf(corpse))
	qdel(candle)
	new /obj/effect/decal/cleanable/ash(get_turf(corpse))
	qdel(corpse)
	ritual_in_progress = FALSE

// -----------------------------------------------------------------------------
// Bull Rage Helmet
// -----------------------------------------------------------------------------
/obj/item/clothing/head/bull_rage
	name = "bull-horned helmet"
	desc = "A heavy helmet adorned with massive bull horns."
	icon = 'icons/SCP/abnormal_objects.dmi'
	icon_state = "bull"
	item_state = "bull"
	body_parts_covered = 0

/obj/item/clothing/head/bull_rage/equipped(mob/user, slot)
	. = ..()
	if(slot == slot_head && isliving(user))
		user.visible_message(SPAN_DANGER("[user] puts on [src] and snorts with uncontrollable rage! The color red must be DESTROYED."))

/obj/item/clothing/head/bull_rage/dropped(mob/user)
	. = ..()
	if(user)
		user.visible_message(SPAN_NOTICE("[user] takes off [src]. The rage subsides."))

// -----------------------------------------------------------------------------
// SCP-173 T-Shirt
// -----------------------------------------------------------------------------
/obj/item/clothing/suit/scp_tshirt
	name = "\"SCP: Secure, Contain, Protect\" t-shirt"
	desc = "A white t-shirt for true SCP enthusiasts. The back features a detailed caricature of SCP-173 with the caption: \"Keep looking at him.\" A blatant breach of the Veil."
	icon = 'icons/SCP/abnormal_objects.dmi'
	icon_state = "scp"
	item_state = "scp"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO

// -----------------------------------------------------------------------------
// Suspicious Apple
// -----------------------------------------------------------------------------
/obj/item/melee/suspicious_apple
	name = "apple"
	desc = "It looks like an ordinary apple. It feels surprisingly sturdy."
	icon = 'icons/obj/food_ingredients.dmi'
	icon_state = "apple"
	force = 5
	throwforce = 8
	w_class = ITEM_SIZE_SMALL
	attack_verb = list("smashed", "splattered", "thwacked")

/obj/item/melee/suspicious_apple/resolve_attackby(atom/A, mob/user)
	. = ..()

// -----------------------------------------------------------------------------
// Boomerang Baseball
// -----------------------------------------------------------------------------
/obj/item/boomerang_baseball
	name = "baseball"
	desc = "A regular baseball. Something about its trajectory seems... off."
	icon = 'icons/SCP/abnormal_objects.dmi'
	icon_state = "baseball"
	item_state = "baseball"
	w_class = ITEM_SIZE_SMALL
	force = 5
	throwforce = 10

/obj/item/boomerang_baseball/throw_at(atom/target, range, speed, mob/thrower, spin, diagonals_first, datum/callback/callback, gentle)
	if(thrower)
		var/turf/throw_target = get_turf(thrower)
		for(var/i = 1 to 5)
			throw_target = get_step(throw_target, turn(thrower.dir, 180))
		if(throw_target)
			target = throw_target
		range = 10
		speed = 1
	return ..()
