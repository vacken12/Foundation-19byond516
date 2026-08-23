/mob/living/scp999
	name = "orange slime"
	desc = "A large, amorphous, gelatinous mass of translucent orange slime. It looks really happy."
	icon = 'icons/SCP/scp-999.dmi'

	icon_state = "SCP-999"
	alpha = 200

	maxHealth = 1500
	health = 1500

	hud_type = /datum/hud/slime
	see_invisible = SEE_INVISIBLE_NOLIGHTING
	see_in_dark = 7
	universal_speak = 1	// 999 can understand and speak every language, although his text gets altered
	speak_emote = list("blubbers", "glubs")
	///Current size multiplier from feeding
	var/resize = 1
	///sound cooldown track
	var/sound_cooldown
	///Sound cooldown
	var/sound_cooldown_time = 5 SECONDS
	///Tracks number of feedings for pixel_y growth
	var/feeding_count = 0

/mob/living/scp999/Initialize()
	. = ..()
	SCP = new /datum/scp(
		src, // Ref to actual SCP atom
		"orange slime", //Name (Should not be the scp desg, more like what it can be described as to viewers)
		SCP_SAFE, //Obj Class
		"999", //Numerical Designation
		SCP_PLAYABLE|SCP_ROLEPLAY
	)
	add_verb(src, /client/proc/scpooc)

	SCP.min_time = 5 MINUTES

//Mechanics

/mob/living/scp999/proc/glubbify(match)
	. = "gl"
	for(var/i = (max(0, length(match) - 3)), i > 0, i--)
		. += "u"
	. += "b"

/mob/living/scp999/attackby(obj/item/O as obj, mob/user as mob)
	if(istype(O, /obj/item/reagent_containers/food/snacks)) //feeding all snacks
		user.visible_message(SPAN_NOTICE("[user] feeds [O] to [name]!"),SPAN_NOTICE("You feed [O] to [name]!"))
		resize *= 1.01
		transform = matrix() * resize
		feeding_count++
		if(feeding_count >= 5)
			feeding_count = 0
			pixel_y += 1
		qdel(O)

//Overrides

/mob/living/scp999/handle_autohiss(message, datum/language/speaking)
	playsound(get_turf(src), 'sounds/scp/999/999_murr.ogg', 65, TRUE)
	var/regex/words = new(@"(\S+)", "ig")

	var/end_char = copytext(message, length(message), length(message) + 1)
	if(end_char in list(".", "?", "!", "-", "~", ":"))
		return words.Replace(copytext(message, 1, length(message)), TYPE_PROC_REF(/mob/living/scp999, glubbify)) + end_char
	else
		return words.Replace(message, TYPE_PROC_REF(/mob/living/scp999, glubbify))

/mob/living/scp999/update_icon()
	if(stat == DEAD)
		icon_state = "SCP-999_d"
	else if(resting || lying)
		icon_state = "SCP-999_rest"
	else
		icon_state = "SCP-999"

/mob/living/scp999/verb/murr()
	set name = "\[Sound\] Murrs"
	set category = "SCP"
	set desc = "Murr."

	if(world.time < sound_cooldown)
		return
	playsound(get_turf(src), 'sounds/scp/999/999_murr.ogg', 65, TRUE)
	sound_cooldown = world.time + sound_cooldown_time

/mob/living/scp999/UnarmedAttack(atom/a)
	if(istype(a, /obj/item/reagent_containers/food/snacks)) 	//Eat snacks from the floor
		visible_message(SPAN_NOTICE("[src] slurps up [a]!"), SPAN_NOTICE("You slurp up [a]!"))
		resize *= 1.01
		transform = matrix() * resize
		feeding_count++
		if(feeding_count >= 5)
			feeding_count = 0
			pixel_y += 1
		qdel(a)
		setClickCooldown(CLICK_CD_ATTACK)
		return
	if(ishuman(a))
		var/mob/living/carbon/human/H = a
		switch(a_intent)
			if(I_HELP)
				H.visible_message(SPAN_NOTICE("[src] gives [a] a big hug!"), SPAN_NOTICE("[src] hugs you, filling you with happiness!"))
				playsound(src.loc, 'sounds/weapons/thudswoosh.ogg', 50, 1, -1)
				H.make_reagent(6, /datum/reagent/medicine/antidepressant/anomalous_happiness)
				H.emote(pick("laugh","giggle"))
			if(I_DISARM)
				H.visible_message(SPAN_WARNING("[src] begins to wrap around [a]'s legs!"), SPAN_WARNING("[src] begins wrapping around your legs!"))
				H.make_reagent(2, /datum/reagent/medicine/antidepressant/anomalous_happiness)
				H.emote(pick("laugh","giggle"))
				if(do_after(src, 1.5 SECONDS, H, bonus_percentage = 100))
					playsound(loc, 'sounds/misc/slip.ogg', 50, 1, -3)
					H.Weaken(6)
					H.Stun(3)
					visible_message(SPAN_WARNING("[src] wraps around [H]'s legs, tripping them!"))
			if(I_HURT)
				H.visible_message(SPAN_WARNING("[src] gives [a] a tickle attack!"), SPAN_WARNING("[src] gives you a tickle attack, filling you with happiness!"))
				H.make_reagent(10, /datum/reagent/medicine/antidepressant/anomalous_happiness)
				H.emote("laugh")
				H.Weaken(6)
	else
		return ..()
