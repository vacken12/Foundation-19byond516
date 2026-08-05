/obj/item/toy/plushie/scp729j
	name = "krol"
	desc = "A yellow krol plushie. It's staring at you. Why is it staring at you?"
	icon = 'icons/SCP/scp-729-J.dmi'
	icon_state = "krol"
	w_class = ITEM_SIZE_NORMAL
	var/list/affected_mobs = list()

/obj/item/toy/plushie/scp729j/Initialize()
	. = ..()
	SCP = new /datum/scp(
		src,
		"krol",
		SCP_THAUMIEL,
		"729-J",
		SCP_MEMETIC
	)
	SCP.memeticFlags = MVISUAL | MSYNCED
	SCP.memetic_proc = TYPE_PROC_REF(/obj/item/toy/plushie/scp729j, apply_fear)
	SCP.compInit()
	START_PROCESSING(SSobj, src)

/obj/item/toy/plushie/scp729j/Destroy()
	STOP_PROCESSING(SSobj, src)
	if(SCP)
		qdel(SCP.meme_comp)
	return ..()

/obj/item/toy/plushie/scp729j/Process()
	if(SCP)
		SCP.meme_comp.check_viewers()
		SCP.meme_comp.activate_memetic_effects()

/obj/item/toy/plushie/scp729j/proc/apply_fear(mob/living/carbon/human/H)
	if(!istype(H) || H.stat == DEAD)
		return

	var/weakref/ref = weakref(H)
	var/fear_level = affected_mobs[ref] || 0
	var/last_trigger = affected_mobs["[ref]_last"] || 0

	if(world.time < last_trigger + 60 SECONDS)
		return

	var/messages = list(
		"The krol's button eyes bore into your soul!",
		"An unnatural dread washes over you as the krol stares!",
		"You feel the krol's gaze piercing through your very being!",
		"The krol's eyes follow your every move...",
		"A chill runs down your spine as you meet the krol's gaze!",
		"The krol's smile seems to widen as you look at it...",
		"You feel like the krol knows all your deepest fears!",
		"The krol's button eyes seem to glow with malice!",
		"You can't shake the feeling that the krol is judging you...",
		"The krol's presence fills you with primal terror!",
		"The krol's gaze feels like it's peeling back your sanity layer by layer...",
		"You feel an ancient, malevolent intelligence watching from behind those button eyes...",
		"The krol's smile doesn't reach its eyes, and that's the most terrifying part...",
		"You realize with horror that the krol has been staring at you this entire time...",
		"Something about the krol's stillness is deeply, fundamentally wrong...",
		"You feel your grip on reality slipping as the krol continues to watch...",
		"The krol's button eyes seem to contain entire worlds of existential dread...",
		"You can feel the krol's presence worming its way into your subconscious...",
		"The krol doesn't blink. It never blinks. Why doesn't it blink?",
		"You feel like the krol is waiting for something... and you're terrified of what it might be..."
	)

	to_chat(H, SPAN_ALERT(pick(messages)))
	H.emote("scream")
	H.Stun(2)
	H.apply_status_effect(/datum/status_effect/jitter, 10 SECONDS)

	var/obj/item/organ/internal/brain/B = H.internal_organs_by_name[BP_BRAIN]
	var/new_level = min(4, fear_level + 1)

	switch(fear_level)
		if(0)
			if(B) B.damage = min(B.max_damage, B.damage + 5)
		if(1)
			H.apply_status_effect(/datum/status_effect/eye_blur, 8 SECONDS)
			if(B) B.damage = min(B.max_damage, B.damage + 10)
		if(2)
			H.apply_status_effect(/datum/status_effect/eye_blur, 12 SECONDS)
			H.apply_status_effect(/datum/status_effect/dizziness, 5 SECONDS)
			if(B) B.damage = min(B.max_damage, B.damage + 15)
		if(3)
			H.apply_status_effect(/datum/status_effect/eye_blur, 15 SECONDS)
			H.apply_status_effect(/datum/status_effect/dizziness, 8 SECONDS)
			H.apply_status_effect(/datum/status_effect/speech/stutter, 10 SECONDS)
			if(B) B.damage = min(B.max_damage, B.damage + 20)
		if(4)
			H.Weaken(5)
			H.apply_status_effect(/datum/status_effect/eye_blur, 20 SECONDS)
			H.apply_status_effect(/datum/status_effect/dizziness, 10 SECONDS)
			H.apply_status_effect(/datum/status_effect/speech/stutter, 15 SECONDS)
			H.apply_status_effect(/datum/status_effect/confusion, 10 SECONDS)
			if(B) B.damage = min(B.max_damage, B.damage + 30)

	affected_mobs[ref] = new_level
	affected_mobs["[ref]_last"] = world.time
	addtimer(CALLBACK(src, PROC_REF(reduce_fear), ref), 2 MINUTES)

/obj/item/toy/plushie/scp729j/proc/reduce_fear(weakref/ref)
	if(!(ref in affected_mobs))
		return
	var/current = affected_mobs[ref]
	if(current <= 0)
		affected_mobs -= ref
		return
	if(current <= 1)
		affected_mobs -= ref
		return

	var/last_trigger = affected_mobs["[ref]_last"] || 0
	if(world.time < last_trigger + 60 SECONDS)
		addtimer(CALLBACK(src, PROC_REF(reduce_fear), ref), 2 MINUTES)
		return

	affected_mobs[ref] = current - 1
	addtimer(CALLBACK(src, PROC_REF(reduce_fear), ref), 2 MINUTES)
