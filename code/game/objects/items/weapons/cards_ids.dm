/* Cards
 * Contains:
 *		DATA CARD
 *		ID CARD
 *		FINGERPRINT CARD HOLDER
 *		FINGERPRINT CARD
 */



/*
 * DATA CARDS - Used for the IC data card reader
 */
/obj/item/card
	name = "card"
	desc = "Does card things."
	icon = 'icons/obj/card.dmi'
	w_class = ITEM_SIZE_TINY
	slot_flags = SLOT_EARS

	drop_sound = SFX_DROP_DISK
	pickup_sound = SFX_PICKUP_DISK

/obj/item/card/data
	name = "data card"
	desc = "A plastic magstripe card for simple and speedy data storage and transfer. This one has a stripe running down the middle."
	icon_state = "data_1"
	var/detail_color = COLOR_ASSEMBLY_ORANGE
	var/function = "storage"
	var/data = "null"
	var/special = null
	var/list/files = list(  )

/obj/item/card/data/Initialize()
	.=..()
	update_icon()
/* Create proc to disable overlays ~~ Lestat
/obj/item/card/data/on_update_icon()
	cut_overlays()
	var/image/detail_overlay = image('icons/obj/card.dmi', src,"[icon_state]-color")
	detail_overlay.color = detail_color
	add_overlay(detail_overlay)
*/
/obj/item/card/data/attackby(obj/item/I, mob/living/user)
	if(istype(I, /obj/item/device/integrated_electronics/detailer))
		var/obj/item/device/integrated_electronics/detailer/D = I
		detail_color = D.detail_color
		update_icon()
	return ..()

/obj/item/card/data/full_color
	desc = "A plastic magstripe card for simple and speedy data storage and transfer. This one has the entire card colored."
	icon_state = "data_2"

/obj/item/card/data/disk
	desc = "A plastic magstripe card for simple and speedy data storage and transfer. This one inexplicibly looks like a floppy disk."
	icon_state = "data_3"

/*
 * ID CARDS
 */

/obj/item/card/emag
	desc = "It's a blank ID card with a magnetic strip and some odd circuitry attached."
	name = "identification card"
	icon_state = "emag"
	item_state = "card-id"
	origin_tech = list(TECH_MAGNET = 2, TECH_ESOTERIC = 2)
	var/uses = 10000

/obj/item/card/emag/resolve_attackby(atom/A, mob/user)
	if(uses<1)
		user.visible_message(SPAN_WARNING("\The [src] fizzles and sparks - it seems it's been used once too often."))
	else
		var/used_uses = A.emag_act(uses, user, src)
		if(used_uses == EMAG_NO_ACT)
			return ..(A, user)

		uses -= used_uses
		A.add_fingerprint(user)
		log_and_message_staff("emagged \an [A].")

	return 1

/obj/item/card/emag/examine(mob/user, distance)
	. = ..()
	if((distance <= 0) && (user.skill_check(SKILL_DEVICES, SKILL_TRAINED) || player_is_antag(user.mind)))
		switch(uses)
			if(10 to INFINITY)
				to_chat(user, SPAN_NOTICE("The card looks to be in a pristine condition!"))
			if(4 to 9)
				to_chat(user, SPAN_NOTICE("The card seems to be in normal working order."))
			if(1 to 3)
				to_chat(user, SPAN_NOTICE("The circuitry has visibly degraded, although the card does still look usable."))
			else
				to_chat(user, SPAN_WARNING("You can tell the components are completely fried; whatever use it may have had before is gone."))

/obj/item/card/emag/Initialize()
	. = ..()
	set_extension(src,/datum/extension/chameleon/emag)

// Fine - Sets uses to random amount between 5 and 15.
/obj/item/card/emag/Conversion914(mode = MODE_ONE_TO_ONE, mob/user = usr)
	switch(mode)
		if(MODE_FINE)
			uses = rand(5, 15)
			visible_message(SPAN_NOTICE("Electricity runs through \the [src] briefly."))
			playsound(src, 'sounds/effects/sparks3.ogg', 50, TRUE)
			return src
	return ..()

/obj/item/card/emag/broken
	uses = 0

/obj/item/card/id
	name = "identification card"
	desc = "A card used to provide ID and determine access."
	icon_state = "base"
	item_state = "card-id"
	slot_flags = SLOT_ID

	var/list/access = list()
	/// The name registered on the card
	var/registered_name = "Unknown"
	var/associated_account_number = 0
	var/list/associated_email_login = list("login" = "", "password" = "")

	var/age = "\[UNSET\]"
	var/blood_type = "\[UNSET\]"
	var/dna_hash = "\[UNSET\]"
	var/fingerprint_hash = "\[UNSET\]"
	var/sex = "\[UNSET\]"
	var/icon/front
	var/icon/side

	//alt titles are handled a bit weirdly in order to unobtrusively integrate into existing ID system
	// Alt-title if applicable, otherwise actual job name.
	var/assignment = null
	/// Actual job name, ignoring the alt-title
	var/rank = null

	/// determines if this ID has claimed a dorm already // TODO: delete this
	var/dorm = 0

	/// Job type to acquire access rights from, if any
	var/job_access_type

	/// What class this ID card represents.
	var/class = CLASS_C

	var/formal_name_prefix
	var/formal_name_suffix

	var/detail_color
	var/extra_details

	var/access_level = 0 // id level from icon. Just for ui

/obj/item/card/id/Initialize()
	.=..()
	if(job_access_type)
		var/datum/job/j = SSjobs.get_by_path(job_access_type)
		if(j)
			rank = j.title
			if(!assignment)
				assignment = rank
			if(!class)
				class = j.class
			access |= j.get_access()
			if(!detail_color)
				detail_color = j.selection_color
	update_icon()
/*
/obj/item/card/id/get_mob_overlay(mob/user_mob, slot)
	var/image/ret = ..()
	ret.add_overlay(overlay_image(ret.icon, "[ret.icon_state]_colors", detail_color, RESET_COLOR))
	return ret

/obj/item/card/id/on_update_icon()
	cut_overlays()
	add_overlay(overlay_image(icon, "[icon_state]_colors", detail_color, RESET_COLOR))
	for(var/detail in extra_details)
		add_overlay(overlay_image(icon, detail, flags=RESET_COLOR))
*/
/obj/item/card/id/CanUseTopic(user)
	if(user in view(get_turf(src)))
		return STATUS_INTERACTIVE

/obj/item/card/id/OnTopic(mob/user, list/href_list)
	if(href_list["look_at_id"])
		if(istype(user))
			user.examinate(src)
			return TOPIC_HANDLED

/obj/item/card/id/examine(mob/user, distance)
	. = ..()
	to_chat(user, "It says '[get_display_name()]'.")
	if(distance <= 1)
		show(user)

/// List of ID cards that can be used in 914 conversion effect
GLOBAL_LIST_INIT(valid_conversion_cards, \
	subtypesof(/obj/item/card/id) - typesof(/obj/item/card/id/syndicate) - /obj/item/card/id/centcom)

/// Associative list of card = list of cards that it can upgrade into
GLOBAL_LIST_EMPTY(conversion_cards)

// 1:1 - Returns random ID card type and copies ALL of our access to it. Nothing gained, nothing lost, just new sprite.
// Fine - Returns an "upgrade" type of our card, but may turn into useless stuff.
// Very Fine - ???
/obj/item/card/id/Conversion914(mode = MODE_ONE_TO_ONE, mob/user = usr)
	switch(mode)
		if(MODE_ONE_TO_ONE)
			var/type_path = pick(GLOB.valid_conversion_cards)
			var/obj/item/card/id/new_id = new type_path(get_turf(src))
			new_id.access = access.Copy()
			CopyInfoToCard(new_id)
			return new_id
		if(MODE_FINE)
			if(prob(7))
				return pick(/obj/item/card/data, /obj/item/deck/cards, /obj/item/deck/tarot)
			if(!LAZYLEN(GLOB.conversion_cards))
				for(var/type_path in GLOB.valid_conversion_cards)
					GLOB.conversion_cards[type_path] = list()
					var/obj/item/card/id/id = new type_path(src)
					var/must_match = max(1, round(length(id.access) * 0.5))
					for(var/type_path_again in GLOB.valid_conversion_cards - type_path)
						var/obj/item/card/id/new_id = new type_path(id)
						// Returns a list of accesses that were in both lists
						var/list/matches = id.access & new_id.access
						if(length(matches) >= must_match && length(id.access) > length(access))
							GLOB.conversion_cards[type_path] |= type_path_again
						QDEL_NULL(new_id)
					QDEL_NULL(id)
			// Let's give it some random shit!
			if(!LAZYLEN(GLOB.conversion_cards[type]) || prob(15))
				var/list/valid_access = get_all_site_access() - access
				if(LAZYLEN(valid_access))
					var/new_access = pick(valid_access)
					access |= new_access
					visible_message(SPAN_NOTICE("\The [src] glows for a moment, as if something passed into it."))
				return src
			var/new_type = pick(GLOB.valid_conversion_cards[type])
			var/obj/item/card/id/new_id = new new_type(get_turf(src))
			return new_id
	return ..()

// Copies most of the info (such as owner and their job) to another card
/obj/item/card/id/proc/CopyInfoToCard(obj/item/card/id/new_id)
	if(!istype(new_id))
		return

	new_id.assignment = assignment
	new_id.age = age
	new_id.front = front
	new_id.side = side
	new_id.formal_name_prefix = formal_name_prefix
	new_id.formal_name_suffix = formal_name_suffix
	new_id.registered_name = registered_name
	new_id.sex = sex
	new_id.access_level = access_level
	new_id.blood_type = blood_type
	new_id.dna_hash = dna_hash
	new_id.fingerprint_hash = fingerprint_hash

/obj/item/card/id/proc/prevent_tracking()
	return 0

/obj/item/card/id/proc/show(mob/user as mob)
	if(front && side)
		send_rsc(user, front, "front.png")
		send_rsc(user, side, "side.png")
	var/datum/browser/popup = new(user, "idcard", name, 780, 600)
	popup.set_content(dat())
	popup.set_title_image(usr.browse_rsc_icon(src.icon, src.icon_state))
	popup.open()
	return

/obj/item/card/id/proc/get_display_name()
	. = "[formal_name_prefix][registered_name][formal_name_suffix]"
	if(class)
		. ="[class] [.]"
	if(assignment)
		. += ", [assignment]"

/obj/item/card/id/proc/set_id_photo(mob/M)
	front = getFlatIcon(M, SOUTH, always_use_defdir = 1)
	front.Crop(9, 18, 23, 32)
	side = getFlatIcon(M, WEST, always_use_defdir = 1)
	side.Crop(9, 18, 23, 32)

/mob/proc/set_id_info(obj/item/card/id/id_card)
	id_card.age = 0

	id_card.formal_name_prefix = initial(id_card.formal_name_prefix)
	id_card.formal_name_suffix = initial(id_card.formal_name_suffix)
	if(client && client.prefs)
		for(var/culturetag in client.prefs.cultural_info)
			var/decl/cultural_info/culture = SSculture.get_culture(client.prefs.cultural_info[culturetag])
			if(culture)
				id_card.formal_name_prefix = "[culture.get_formal_name_prefix()][id_card.formal_name_prefix]"
				id_card.formal_name_suffix = "[id_card.formal_name_suffix][culture.get_formal_name_suffix()]"

	id_card.registered_name = real_name

	id_card.sex = gender2text(get_sex())
	id_card.set_id_photo(src)

	if(dna)
		id_card.blood_type		= dna.b_type
		id_card.dna_hash		= dna.unique_enzymes
		id_card.fingerprint_hash= md5(dna.uni_identity)

/mob/living/carbon/human/set_id_info(obj/item/card/id/id_card)
	..()
	id_card.age = age

/obj/item/card/id/proc/dat()
	var/clean_name = "[formal_name_prefix][registered_name][formal_name_suffix]"
	var/class_color = ""
	switch(class)
		if(CLASS_A)
			class_color = "#c41e3a"
		if(CLASS_B)
			class_color = "#1e5ac4"
		if(CLASS_C)
			class_color = "#2a8c2a"
		if(CLASS_D)
			class_color = "#ffa200"
		if(CLASS_CI)
			class_color = "#004208"
		else
			class_color = "#556677"

	if(istype(src, /obj/item/card/id/mtf/o5rep))
		class_color = "#000000"
	if(istype(src, /obj/item/card/id/gocrep))
		class_color = "#2600ff"
	if(istype(src, /obj/item/card/id/tribunal))
		class_color = "#84009e"
	if(istype(src, /obj/item/card/id/ethics))
		class_color = "#075600"

	var/list/dat = list("<style>")
	dat += "body{margin:0;padding:0;background:#1a1a2e;font-family:'Segoe UI',Arial,sans-serif;display:flex;justify-content:center;align-items:center;min-height:100vh;}"
	dat += ".id-card{width:500px;background:linear-gradient(160deg,#e8e4e0 0%,#f5f0ea 50%,#e0dcd6 100%);border-radius:14px;overflow:hidden;box-shadow:0 8px 32px rgba(0,0,0,0.4),0 2px 8px rgba(0,0,0,0.2);border:1px solid #d4cfc8;position:relative;}"
	dat += ".id-card::before{content:'';position:absolute;top:0;left:0;right:0;height:4px;background:linear-gradient(90deg,[class_color],[class_color] 50%,transparent 50%,transparent 100%);background-size:12px 4px;}"
	dat += ".card-header{background:[class_color];padding:8px 16px;display:flex;justify-content:space-between;align-items:center;gap:8px;}"
	dat += ".card-header .header-left{display:flex;align-items:center;gap:8px;}"
	dat += ".card-header .scp-logo{flex-shrink:0;width:30px;height:30px;}"
	dat += ".card-header .scp-logo svg{width:100%;height:100%;display:block;}"
	dat += ".card-header .scp-logo svg path{fill:rgba(255,255,255,0.85);}"
	dat += ".card-header .org-name{color:#d0ddf0;font-size:11px;font-weight:600;letter-spacing:1.5px;text-transform:uppercase;text-shadow:0 1px 2px rgba(0,0,0,0.3);}"
	dat += ".card-header .class-badge{background:[class_color];color:#fff;font-size:10px;font-weight:700;padding:3px 10px;border-radius:14px;overflow:hidden;box-shadow:0 8px 32px rgba(0,0,0,0.4),0 2px 8px rgba(0,0,0,0.2);border:1px solid #d4cfc8;position:relative;letter-spacing:1px;}"
	dat += ".card-body{padding:16px;display:flex;gap:14px;}"
	dat += ".card-photo{flex-shrink:0;width:100px;height:130px;background:linear-gradient(180deg,#d4d0ca,#c8c4be);border-radius:6px;border:2px solid #b8b4ae;overflow:hidden;position:relative;display:flex;flex-direction:column;align-items:center;justify-content:center;}"
	dat += ".card-photo img{width:90px;height:auto;image-rendering:pixelated;}"
	dat += ".card-photo .photo-id-label{position:absolute;bottom:0;left:0;right:0;background:rgba(0,0,0,0.6);color:#ccc;font-size:7px;text-align:center;padding:2px;letter-spacing:2px;text-transform:uppercase;}"
	dat += ".card-info{flex:1;min-width:100px;}"
	dat += ".info-row{display:flex;margin-bottom:5px;border-bottom:1px solid rgba(0,0,0,0.06);padding-bottom:3px;}"
	dat += ".info-label{width:60px;flex-shrink:0;color:#7a7a88;font-size:9px;font-weight:600;text-transform:uppercase;letter-spacing:0.5px;padding-top:2px;}"
	dat += ".info-value{font-size:12px;color:#2a2a3a;font-weight:500;word-break:break-word;}"
	dat += ".info-value.class-value{font-weight:700;color:[class_color];}"
	dat += ".info-value.name-value{font-weight:700;font-size:13px;color:#1a1a2a;}"
	dat += ".card-footer{border-top:1px solid rgba(0,0,0,0.1);padding:10px 16px;background:rgba(0,0,0,0.02);display:flex;justify-content:space-between;align-items:center;}"
	dat += ".footer-hash{color:#8a8a9a;font-size:8px;font-family:'Consolas','Courier New',monospace;}"
	dat += ".footer-logo{color:#8a8a9a;font-size:9px;font-weight:600;letter-spacing:2px;opacity:0.5;}"
	dat += ".fingerprint-dots{display:flex;gap:2px;margin-top:2px;}"
	dat += ".fingerprint-dots span{width:8px;height:8px;border-radius:50%;background:#666;opacity:0.4;}"
	dat += "</style><div class='id-card'>"
	dat += "<div class='card-header'><div class='header-left'><span class='scp-logo'><svg role='img' viewBox='0 0 24 24' xmlns='http://www.w3.org/2000/svg'><path d='M11.577 5.064v.555l-.045.01c-.026 0-.148.015-.272.028a7.023 7.023 0 0 0-3.146 1.14A7.053 7.053 0 0 0 6.18 8.73a7.007 7.007 0 0 0-.507 6.893c.05.103.09.19.09.195 0 0-.236.145-.528.313a34.79 34.79 0 0 0-.544.317c-.014.01.013.063.196.38a8.68 8.68 0 0 0 .22.37 26.001 26.001 0 0 0 .55-.312c.297-.173.544-.313.55-.313.003 0 .052.063.106.14a7.057 7.057 0 0 0 1.801 1.74 7.258 7.258 0 0 0 1.69.826 6.992 6.992 0 0 0 4.41 0 7.228 7.228 0 0 0 1.69-.825 7.01 7.01 0 0 0 1.816-1.764c.063-.09.117-.162.12-.162.002 0 .244.138.536.306.292.17.539.31.548.314.013.01.064-.075.23-.362.192-.331.21-.371.195-.383-.01-.01-.255-.15-.546-.317a16.77 16.77 0 0 1-.527-.313s.036-.082.08-.174a7.033 7.033 0 0 0 .566-4.14 7.074 7.074 0 0 0-1.084-2.73 7.03 7.03 0 0 0-1.622-1.714 6.664 6.664 0 0 0-1.08-.663 6.834 6.834 0 0 0-2.378-.697l-.27-.028-.048-.01v-1.11h-.863zm0 3.102v1.25h-.492c-.285 0-.49 0-.487.01.01.032 1.428 2.775 1.432 2.775.004 0 1.42-2.743 1.434-2.774.002-.01-.213-.01-.51-.01h-.514V6.915h.05c.151 0 .606.076.912.152a5.304 5.304 0 0 1 1.137.42 5.64 5.64 0 0 1 1.165.755c.165.136.589.567.73.742.21.26.406.545.567.828.086.152.263.52.33.69a5.74 5.74 0 0 1 .115 3.918c-.096.29-.27.703-.294.703-.013 0-1.993-1.14-2.013-1.16-.013-.011.022-.08.223-.427.13-.228.24-.418.24-.424 0-.011.007-.011-.25-.022-.102 0-.195-.01-.204-.011-.01 0-.105-.01-.215-.01s-.224-.01-.254-.012c-.03 0-.126-.01-.216-.011-.088 0-.183-.01-.21-.011-.027 0-.134-.01-.237-.012-.104 0-.205-.01-.225-.01-.02 0-.118-.01-.22-.011-.102 0-.203-.01-.224-.011-.02 0-.13-.01-.243-.011-.112 0-.212-.01-.22-.011-.042-.01-.4-.018-.4-.012 0 0 .307.484.682 1.067l.843 1.31c.146.226.163.25.176.233.008-.011.124-.21.259-.443l.245-.424.032.019 1.013.584c.538.31.978.57.978.575 0 .016-.16.23-.29.39a8.634 8.634 0 0 1-.718.728 6.278 6.278 0 0 1-.76.54 7.585 7.585 0 0 1-.817.403 5.743 5.743 0 0 1-4.236 0c-.2-.08-.634-.292-.816-.403a6.23 6.23 0 0 1-.76-.54 8.363 8.363 0 0 1-.696-.7 4.14 4.14 0 0 1-.29-.383c.002 0 .443-.257.98-.567l1.01-.583.034-.021.235.407c.13.224.24.416.248.427.011.017.02.01.08-.086.036-.058.132-.21.213-.333l.267-.415c.114-.18.485-.756.583-.906l.242-.377.255-.396a.682.682 0 0 0 .058-.101c0-.01-.026-.01-.083-.01-.046 0-.15.01-.23.012-.08 0-.182.01-.226.01-.088.01-.239.014-.453.023-.075 0-.172.01-.216.01-.044 0-.14.01-.216.012-.137.01-.26.012-.45.022-.058 0-.212.01-.342.016-.13.01-.285.013-.342.016-.059 0-.153.01-.21.01-.263.014-.349.02-.349.027 0 0 .113.203.252.443l.253.437-.03.017c-.093.06-1.996 1.153-2.004 1.153-.013 0-.114-.214-.19-.406a5.79 5.79 0 0 1-.406-2.49 5.765 5.765 0 0 1 1.291-3.287c.143-.174.567-.606.732-.742.378-.313.73-.54 1.164-.756.4-.196.725-.317 1.137-.42.31-.077.733-.148.9-.15h.061zM8.531.806l-.168.964c-.088.513-.165.94-.17.947a.832.832 0 0 1-.164.077 10.594 10.594 0 0 0-6.498 8.22 2.255 2.255 0 0 1-.04.215c-.02.053-.064.467-.084.825a15.195 15.195 0 0 0 0 1.134c.013.235.033.455.066.736l.024.199-.043.04a44.252 44.252 0 0 1-.328.303l-.2.183c-.09.085-.106.1-.562.522-.198.18-.36.335-.364.34-.003 0 .132.246.299.536l1.738 3.01a200.286 200.286 0 0 0 1.446 2.484c.006 0 .091-.03.19-.066l.468-.171c.95-.348 1.182-.432 1.19-.432a.384.384 0 0 1 .075.053c.197.165.681.506 1 .704a11.19 11.19 0 0 0 1.898.926 10.64 10.64 0 0 0 4.967.593 10.69 10.69 0 0 0 2.583-.647c.106-.042.203-.078.215-.08.059-.01.404-.167.745-.34.553-.28 1.037-.58 1.545-.96l.208-.152.056.017.089.028a133.24 133.24 0 0 1 1.343.419c.015.01.077.025.14.043l.213.067a.612.612 0 0 0 .11.028c.013 0 3.486-6.017 3.482-6.027-.003-.01-.21-.182-1.076-.904l-.415-.347c-.02-.02-.02-.023.002-.18.12-.844.134-1.68.045-2.56a10.59 10.59 0 0 0-5.284-8.136 11.63 11.63 0 0 0-1.226-.6c-.05-.02-.092-.045-.094-.054-.003-.01-.104-.452-.223-.983l-.222-.984c-.005-.017-.18-.018-3.489-.018h-3.48Zm6.395.55a183.046 183.046 0 0 1 .426 1.832c.008.03.02.037.213.11.425.165.93.4 1.282.597a9.974 9.974 0 0 1 5.106 7.923c.035.432.042 1.199.012 1.558-.028.345-.081.75-.143 1.093l-.013.073.048.046a5.893 5.893 0 0 0 .255.219c.006.01.062.053.123.102l.214.177.41.344c.413.345.384.318.37.34-.004.01-.66 1.142-1.452 2.516-.867 1.503-1.45 2.5-1.458 2.5-.01 0-.095-.024-.191-.053l-.213-.064a44.667 44.667 0 0 1-.857-.262c-.012-.01-.043-.015-.07-.022-.027-.01-.058-.016-.07-.022-.012-.01-.055-.02-.097-.03l-.207-.062c-.13-.04-.132-.04-.16-.02l-.18.145c-.261.21-.743.56-.773.56a.77.77 0 0 0-.106.062 10.05 10.05 0 0 1-4.744 1.559 16.157 16.157 0 0 1-1.284 0c-1.405-.105-2.64-.443-3.845-1.05a10.14 10.14 0 0 1-1.764-1.131.565.565 0 0 0-.088-.066.995.995 0 0 1-.117-.095l-.104-.09-.05.01a5.057 5.057 0 0 0-.466.164 60.002 60.002 0 0 1-.528.195l-.529.193a2.303 2.303 0 0 1-.188.066c-.006 0-.666-1.134-1.466-2.52l-1.455-2.52.037-.031.214-.202.248-.233.173-.164c.056-.054.128-.12.16-.15l.1-.09a41.97 41.97 0 0 1 .41-.385l.072-.07-.015-.077a8.382 8.382 0 0 1-.118-1c0-.087-.006-.32-.01-.518A9.967 9.967 0 0 1 6.46 4.329a9.862 9.862 0 0 1 2.178-1.1c.124-.044.13-.048.138-.082.011-.043.081-.437.214-1.202l.103-.586.005-.024h2.91c2.765 0 2.912 0 2.918.018z'/></svg></span><span class='org-name'>SCP Foundation</span></div><span class='class-badge'>[class]</span></div>"
	dat += "<div class='card-body'>"
	if(front && side)
		dat += "<div class='card-photo'><img src=front.png><div class='photo-id-label'>IDENTIFICATION</div></div>"
	else
		dat += "<div class='card-photo'><div style='color:#8a8a9a;font-size:9px;text-align:center;'>NO<br>PHOTO</div><div class='photo-id-label'>IDENTIFICATION</div></div>"
	dat += "<div class='card-info'>"
	dat += "<div class='info-row'><span class='info-label'>Name</span><span class='info-value name-value'>[clean_name]</span></div>"
	dat += "<div class='info-row'><span class='info-label'>Sex</span><span class='info-value'>[sex]</span></div>"
	dat += "<div class='info-row'><span class='info-label'>Age</span><span class='info-value'>[age]</span></div>"
	dat += "<div class='info-row'><span class='info-label'>Job</span><span class='info-value'>[assignment ? assignment : "N/A"]</span></div>"
	dat += "<div class='info-row'><span class='info-label'>Level</span><span class='info-value class-value'>[access_level]</span></div>"
	dat += "<div class='info-row'><span class='info-label'>Blood</span><span class='info-value'>[blood_type]</span></div>"
	dat += "<div class='info-row'><span class='info-label'>DNA</span><span class='info-value' style='font-size:9px;font-family:Consolas,monospace;color:#555;'>[dna_hash]</span></div>"
	dat += "<div class='fingerprint-dots'>"

	// Generate fingerprint visual representation
	var/fp_len = length(fingerprint_hash)
	for(var/i = 1 to min(fp_len, 10))
		dat += "<span></span>"

	dat += "</div></div></div>"
	dat += "<div class='card-footer'><span class='footer-hash'>#[copytext(md5(registered_name),1,8)]</span><span class='footer-logo'>◆ SCP ◆</span></div>"
	dat += "</div>"
	return jointext(dat,null)

/obj/item/card/id/attack_self(mob/user as mob)
	user.visible_message("\The [user] shows you: [icon2html(src, viewers(get_turf(src)))] [src.name]. The assignment on the card: [src.assignment]",\
		"You flash your ID card: [icon2html(src, viewers(get_turf(src)))] [src.name]. The assignment on the card: [src.assignment]")

	src.add_fingerprint(user)
	return

/obj/item/card/id/GetAccess()
	return access

/obj/item/card/id/GetIdCard()
	return src

/obj/item/card/id/verb/read()
	set name = "Read ID Card"
	set category = "Object"
	set src in usr

	to_chat(usr, text("[icon2html(src, usr)] []: The current assignment on the card is [].", src.name, src.assignment))
	to_chat(usr, "The blood type on the card is [blood_type].")
	to_chat(usr, "The DNA hash on the card is [dna_hash].")
	to_chat(usr, "The fingerprint hash on the card is [fingerprint_hash].")
	return

/obj/item/card/id/captains_spare
	name = "captain's spare ID"
	desc = "The spare ID of the High Lord himself."
	access_level = 5
	item_state = "gold_id"
	registered_name = "Captain"
	assignment = "Captain"
	detail_color = COLOR_AMBER

/obj/item/card/id/captains_spare/New()
	access = get_all_site_access()
	..()

/obj/item/card/id/synthetic
	name = "\improper Synthetic ID"
	desc = "Access module for lawed synthetics."
	access_level = 5
	icon_state = "robot_base"
	assignment = "Synthetic"
	detail_color = COLOR_AMBER

/obj/item/card/id/synthetic/New()
	access = get_all_site_access() + ACCESS_SYNTH
	..()

/obj/item/card/id/centcom
	name = "\improper CentCom. ID"
	desc = "An ID straight from Cent. Com."
	access_level = 5
	registered_name = "Central Command"
	assignment = "General"
	color = COLOR_GRAY40
	detail_color = COLOR_COMMAND_BLUE
	extra_details = list("goldstripe")

/obj/item/card/id/centcom/New()
	access = get_all_centcom_access()
	..()

/obj/item/card/id/centcom/station/New()
	..()
	access |= get_all_site_access()

/obj/item/card/id/centcom/ERT
	name = "\improper Mobile Task Force ID"
	assignment = "Mobile Task Force"
	access_level = 5

/obj/item/card/id/centcom/ERT/New()
	..()
	access |= get_all_site_access()

/obj/item/card/id/all_access
	name = "\improper Administrator's spare ID"
	desc = "The spare ID of the Lord of Lords himself."
	access_level = 5
	registered_name = "Administrator"
	assignment = "Administrator"
	detail_color = COLOR_MAROON
	extra_details = list("goldstripe")

/obj/item/card/id/all_access/New()
	access = get_access_ids()
	..()

// Department-flavor IDs

/obj/item/card/id/security
	name = "identification card"
	desc = "A card issued to security staff."
//	job_access_type = /datum/job/officer
	color = COLOR_OFF_WHITE
	detail_color = COLOR_MAROON

/obj/item/card/id/civilian
	name = "identification card"
	desc = "A card issued to civilian staff."
	job_access_type = DEFAULT_JOB_TYPE
	detail_color = COLOR_CIVIE_GREEN

/obj/item/card/id/civilian/chaplain
	job_access_type = /datum/job/chaplain

/*
***************
***SCP CARDS***
***************
*/

// Currently, cards have to be added for each job and have their own unique identifier if we want access to be made more unique. So that's what we're doing here.

// TEMP CARDS

/obj/item/card/id/seclvl1
	name = "security ID"
	desc = "A light blue card. Seems almost as unimportant as the person itself."
	access_level = 1
	icon_state = "securitylvl1"
	item_state = "Sec_ID1"
	job_access_type = /datum/job/enlistedofficerlcz

/obj/item/card/id/seclvl2
	name = "security ID"
	desc = "A dark purple ID. Looks important. The person wearing it, not at all."
	access_level = 2
	icon_state = "securitylvl2"
	item_state = "Sec_ID2"
	job_access_type = /datum/job/juneng

/obj/item/card/id/seclvl3
	name = "security ID"
	desc = "A dark blue ID. Looks important. The person wearing it not so much."
	access_level = 3
	icon_state = "securitylvl3"
	item_state = "Sec_ID3"
	job_access_type = /datum/job/eng

/obj/item/card/id/seclvl4
	name = "security ID"
	desc = "A teal ID. Looks cool."
	access_level = 4
	icon_state = "securitylvl4"
	item_state = "Sec_ID4"
	job_access_type = /datum/job/seneng

//ENGINEERING

/obj/item/card/id/seclvl2eng
	name = "security ID"
	desc = "A dark purple ID. Looks important. The person wearing it, not at all."
	access_level = 2
	icon_state = "securitylvl2"
	item_state = "Sec_ID2"
	job_access_type = /datum/job/juneng

/obj/item/card/id/seclvl3eng
	name = "security ID"
	desc = "A dark blue ID. Looks important. The person wearing it not so much."
	access_level = 3
	icon_state = "securitylvl3"
	item_state = "Sec_ID3"
	job_access_type = /datum/job/eng

/obj/item/card/id/seclvl4eng
	name = "security ID"
	desc = "A teal ID. Looks cool."
	access_level = 4
	icon_state = "securitylvl4"
	item_state = "Sec_ID4"
	job_access_type = /datum/job/seneng


/obj/item/card/id/seclvl5eng
	name = "security ID"
	desc = "A teal ID. Looks cool."
	access_level = 5
	icon_state = "securitylvl5"
	item_state = "Sec_ID5"
	job_access_type = /datum/job/chief_engineer
	class = CLASS_A

/obj/item/card/id/seclvl3it_tech
	name = "security ID"
	desc = "A dark blue ID. Looks important. The person wearing it not so much."
	access_level = 3
	icon_state = "securitylvl3"
	item_state = "Sec_ID3"
	job_access_type = /datum/job/it_tech

// JUNIOR GUARD ID'S

/obj/item/card/id/junseclvl1lcz
	name = "security ID"
	desc = "A light blue card. Seems almost as unimportant as the person itself."
	access_level = 1
	icon_state = "securitylvl1"
	item_state = "Sec_ID1"
	job_access_type = /datum/job/guardlcz

/obj/item/card/id/junseclvl1ez
	name = "security ID"
	desc = "A light blue card. Seems almost as unimportant as the person itself."
	access_level = 1
	icon_state = "securitylvl1"
	item_state = "Sec_ID1"
	job_access_type = /datum/job/guardez

/obj/item/card/id/junseclvl2hcz
	name = "security ID"
	desc = "A dark purple ID. Looks important. The person wearing it, not at all."
	access_level = 2
	icon_state = "securitylvl2"
	item_state = "Sec_ID2"
	job_access_type = /datum/job/guardhcz

// GUARD ID'S

/obj/item/card/id/junseclvl2lcz
	name = "security ID"
	desc = "A dark purple ID. Looks important. The person wearing it, not at all."
	access_level = 2
	icon_state = "securitylvl2"
	item_state = "Sec_ID2"
	job_access_type = /datum/job/enlistedofficerlcz

/obj/item/card/id/junseclvl2ez
	name = "security ID"
	desc = "A dark purple ID. Looks important. The person wearing it, not at all."
	access_level = 2
	icon_state = "securitylvl2"
	item_state = "Sec_ID2"
	job_access_type = /datum/job/enlistedofficerez

/obj/item/card/id/junseclvl3hcz
	name = "security ID"
	desc = "A dark blue ID. Looks important. The person wearing it not so much."
	access_level = 3
	icon_state = "securitylvl3"
	item_state = "Sec_ID3"
	job_access_type = /datum/job/enlistedofficerhcz

// GUARD ID'S.
/obj/item/card/id/seclvl3lcz
	name = "security ID"
	desc = "A dark purple ID. Looks important. The person wearing it, not at all."
	access_level = 3
	icon_state = "securitylvl3"
	item_state = "Sec_ID3"
	job_access_type = /datum/job/ncoofficerlcz

/obj/item/card/id/seclvl3ez
	name = "security ID"
	desc = "A dark blue ID. Looks important. The person wearing it not so much."
	access_level = 3
	icon_state = "securitylvl3"
	item_state = "Sec_ID3"
	job_access_type = /datum/job/ncoofficerez

/obj/item/card/id/seclvl3raisa
	name = "security ID"
	desc = "A dark blue ID. Looks important. The person wearing it not so much."
	access_level = 3
	icon_state = "securitylvl3"
	item_state = "Sec_ID3"
	job_access_type = /datum/job/raisa

/obj/item/card/id/seclvl2lczdivision
	name = "security ID"
	desc = "A light blue card. Seems almost as unimportant as the person itself."
	access_level = 2
	icon_state = "securitylvl2"
	item_state = "Sec_ID2"
	access = list(
		ACCESS_SEC_COMMS,
		ACCESS_SECURITY_LVL1,
		ACCESS_SECURITY_LVL2,
		ACCESS_SCIENCE_LVL1,
		ACCESS_SCIENCE_LVL2,
		ACCESS_MEDICAL_LVL1,
		ACCESS_DCLASS_KITCHEN,
		ACCESS_DCLASS_BOTANY,
		ACCESS_DCLASS_MINING,
		ACCESS_DCLASS_JANITORIAL,
		ACCESS_DCLASS_MEDICAL,
		ACCESS_DCLASS_LUXURY
	)
/obj/item/card/id/lcz_medicaldoctor
	name = "security ID"
	desc = "A light blue card. Seems almost as unimportant as the person itself."
	access_level = 2
	icon_state = "securitylvl2"
	item_state = "Sec_ID2"
	assignment = "LCZ Medical Doctor"
	access = list(
		ACCESS_SEC_COMMS,
		ACCESS_SECURITY_LVL1,
		ACCESS_SECURITY_LVL2,
		ACCESS_SCIENCE_LVL1,
		ACCESS_SCIENCE_LVL2,
		ACCESS_MEDICAL_LVL1,
		ACCESS_MEDICAL_LVL2,
		ACCESS_MEDICAL_LVL3,
		ACCESS_MEDICAL_EQUIP,
		ACCESS_DCLASS_KITCHEN,
		ACCESS_DCLASS_BOTANY,
		ACCESS_DCLASS_MINING,
		ACCESS_DCLASS_JANITORIAL,
		ACCESS_DCLASS_MEDICAL,
		ACCESS_DCLASS_LUXURY
	)

// Riot Control Unit Sergeant
/obj/item/card/id/seclvl2lczdivision2
	name = "security ID"
	desc = "A light blue card. Seems almost as unimportant as the person itself."
	access_level = 2
	icon_state = "securitylvl2"
	item_state = "Sec_ID2"
	access = list(
		ACCESS_SEC_COMMS,
		ACCESS_SECURITY_LVL1,
		ACCESS_SECURITY_LVL2,
		ACCESS_SCIENCE_LVL1,
		ACCESS_SCIENCE_LVL2,
		ACCESS_ARMORY,
		ACCESS_DCLASS_KITCHEN,
		ACCESS_DCLASS_BOTANY,
		ACCESS_DCLASS_MINING,
		ACCESS_DCLASS_JANITORIAL,
		ACCESS_DCLASS_MEDICAL,
		ACCESS_DCLASS_LUXURY
	)

// Riot Control Unit Guard
/obj/item/card/id/seclvl1lczdivision2
	name = "security ID"
	desc = "A light blue card. Seems almost as unimportant as the person itself."
	access_level = 2
	icon_state = "securitylvl2"
	item_state = "Sec_ID2"
	access = list(
		ACCESS_SEC_COMMS,
		ACCESS_SECURITY_LVL1,
		ACCESS_SECURITY_LVL2,
		ACCESS_SCIENCE_LVL1,
		ACCESS_SCIENCE_LVL2,
		ACCESS_ARMORY,
		ACCESS_DCLASS_KITCHEN,
		ACCESS_DCLASS_BOTANY,
		ACCESS_DCLASS_MINING,
		ACCESS_DCLASS_JANITORIAL,
		ACCESS_DCLASS_MEDICAL,
		ACCESS_DCLASS_LUXURY
	)

/obj/item/card/id/seclvl3lczdivision3
	name = "security ID"
	desc = "A dark blue ID. Looks important. The person wearing it not so much."
	access_level = 3
	icon_state = "securitylvl3"
	item_state = "Sec_ID3"
	access = list(
		ACCESS_SEC_COMMS,
		ACCESS_SECURITY_LVL1,
		ACCESS_SECURITY_LVL2,
		ACCESS_SCIENCE_LVL1,
		ACCESS_SCIENCE_LVL2,
		ACCESS_BRIG,
		ACCESS_DCLASS_KITCHEN,
		ACCESS_DCLASS_BOTANY,
		ACCESS_DCLASS_MINING,
		ACCESS_DCLASS_JANITORIAL,
		ACCESS_DCLASS_MEDICAL,
		ACCESS_DCLASS_LUXURY
	)

/obj/item/card/id/seclvl2lczdivision3
	name = "security ID"
	desc = "A light blue card. Seems almost as unimportant as the person itself."
	access_level = 2
	icon_state = "securitylvl2"
	item_state = "Sec_ID2"
	access = list(
		ACCESS_SEC_COMMS,
		ACCESS_SECURITY_LVL1,
		ACCESS_SECURITY_LVL2,
		ACCESS_SCIENCE_LVL1,
		ACCESS_SCIENCE_LVL2,
		ACCESS_BRIG,
		ACCESS_DCLASS_KITCHEN,
		ACCESS_DCLASS_BOTANY,
		ACCESS_DCLASS_MINING,
		ACCESS_DCLASS_JANITORIAL,
		ACCESS_DCLASS_MEDICAL,
		ACCESS_DCLASS_LUXURY
	)

/obj/item/card/id/seclvl3hcz
	name = "security ID"
	desc = "A dark blue ID. Looks important. The person wearing it not so much."
	access_level = 3
	icon_state = "securitylvl3"
	item_state = "Sec_ID3"
	job_access_type = /datum/job/ncoofficerhcz

// ZC ID'S

/obj/item/card/id/zcseclvl4hcz
	name = "security ID"
	desc = "A dark blue ID. Looks important. The person wearing it not so much."
	access_level = 4
	icon_state = "securitylvl4"
	item_state = "Sec_ID4"
	job_access_type = /datum/job/ltofficerhcz
	class = CLASS_B

/obj/item/card/id/zcseclvl4lcz
	name = "security ID"
	desc = "A dark blue ID. Looks important. The person wearing it not so much."
	access_level = 4
	icon_state = "securitylvl4"
	item_state = "Sec_ID4"
	job_access_type = /datum/job/ltofficerlcz
	class = CLASS_B

/obj/item/card/id/zcseclvl4ez
	name = "security ID"
	desc = "A teal ID. Looks cool."
	access_level = 4
	icon_state = "securitylvl4"
	item_state = "Sec_ID4"
	job_access_type = /datum/job/ltofficerez
	class = CLASS_B

// GC ID.

/obj/item/card/id/gcseclvl5
	name = "security ID"
	desc = "A dark purple ID. Looks important."
	access_level = 5
	icon_state = "securitylvl5"
	item_state = "Sec_ID5"
	job_access_type = /datum/job/hos
	class = CLASS_A

// SCIENCE

/obj/item/card/id/sciencelvl1
	name = "science ID"
	desc = "A light blue ID. Haven't you seen a janitor with this before?"
	access_level = 1
	icon_state = "sciencelvl1"
	item_state = "Science_ID1"
	job_access_type = /datum/job/juniorscientist

/obj/item/card/id/sciencelvl2
	name = "science ID"
	desc = "A bright yellow ID. Looks ordinary?"
	access_level = 2
	icon_state = "sciencelvl2"
	item_state = "Science_ID2"
	job_access_type = /datum/job/scientist

/obj/item/card/id/sciencelvl3
	name = "science ID"
	desc = "A dark yellow ID. Looks cool, the person wearing it, not so much."
	access_level = 3
	icon_state = "sciencelvl3"
	item_state = "Science_ID3"
	job_access_type = /datum/job/seniorscientist

/obj/item/card/id/sciencelvl2robo
	name = "science ID"
	desc = "A bright yellow ID. Looks ordinary?"
	access_level = 2
	icon_state = "sciencelvl2"
	item_state = "Science_ID2"
	job_access_type = /datum/job/roboticist

/obj/item/card/id/sciencelvl3robo
	name = "science ID"
	desc = "An orange ID. Looks important."
	access_level = 4
	icon_state = "sciencelvl4"
	item_state = "Science_ID4"
	job_access_type = /datum/job/seniorroboticist

/obj/item/card/id/sciencelvl4
	name = "science ID"
	desc = "An orange ID. Looks important."
	access_level = 4
	icon_state = "sciencelvl4"
	item_state = "Science_ID4"
	//job_access_type = /datum/job/ard

/obj/item/card/id/sciencelvlp
	name = "science ID"
	desc = "An orange ID. Looks important."
	access_level = 3
	icon_state = "sciencelvl3"
	item_state = "Science_ID3"
	job_access_type = /datum/job/mentalist

/obj/item/card/id/sciencelvlps
	name = "science ID"
	desc = "An orange ID. Looks important."
	access_level = 4
	icon_state = "sciencelvl4"
	item_state = "Science_ID4"
	job_access_type = /datum/job/seniormentalist

/obj/item/card/id/sciencelvl5
	name = "science ID"
	desc = "A red ID. Looks like the person wearing this won't give it up easy."
	access_level = 5
	icon_state = "sciencelvl5"
	item_state = "Science_ID5"
	job_access_type = /datum/job/rd
	class = CLASS_B

// ADMIN
/obj/item/card/id/adminlvl1
	name = "administration ID"
	desc = "A black ID. Looks like the person wearing this won't give it up easy."
	access_level = 1
	icon_state = "adminlvl1"
	item_state = "Admin_ID"
//	job_access_type = /datum/job/rd

/obj/item/card/id/adminlvl2
	name = "administration ID"
	desc = "A black ID. Looks like the person wearing this won't give it up easy."
	access_level = 2
	icon_state = "adminlvl2"
	item_state = "Admin_ID"
//	job_access_type = /datum/job/rd

/obj/item/card/id/adminlvl3
	name = "administration ID"
	desc = "A black ID. Looks like the person wearing this won't give it up easy."
	access_level = 3
	icon_state = "adminlvl3"
	item_state = "Admin_ID"
	job_access_type = /datum/job/goirep
	rank = "Карта доступа 3 административного уровня"
	assignment = "Карта доступа 3 административного уровня"
	class = CLASS_A

/obj/item/card/id/gocrep
	name = "GOI represantive ID"
	desc = "A blue ID. Looks like the person wearing this won't give it up easy."
	access_level = 5
	icon_state = "goc"
	item_state = "goc"
	job_access_type = /datum/job/goirep
	class = CLASS_A

/obj/item/card/id/mcid
	name = "Marshall, Carter, and Dark corporate liaison ID"
	desc = "A golden ID. Looks like the person wearing this won't give it up easy."
	access_level = 5
	icon_state = "mcid"
	item_state = "mcid"
	job_access_type = /datum/job/goirep
	rank = "Представитель корпорации Маршалл, Картер и Дарк"
	assignment = "Представитель корпорации Маршалл, Картер и Дарк"
	class = CLASS_A

/obj/item/card/id/adminlvl4
	name = "administration ID"
	desc = "A black ID. Looks like the person wearing this won't give it up easy."
	access_level = 4
	icon_state = "adminlvl4"
	item_state = "Admin_ID"
	job_access_type = /datum/job/hop
	rank = "Карта доступа 4 административного уровня"
	assignment = "Карта доступа 4 административного уровня"
	class = CLASS_A

/obj/item/card/id/hop
	name = "site manager ID"
	desc = "A black ID. Looks like the person wearing this won't give it up easy."
	access_level = 4
	icon_state = "adminlvl4"
	item_state = "Admin_ID"
	job_access_type = /datum/job/hop
	rank = "Менеджер Зоны"
	assignment = "Менеджер Зоны"
	class = CLASS_A

/obj/item/card/id/adminlvl5
	name = "administration ID"
	desc = "A black ID. Looks like the person wearing this won't give it up easy."
	access_level = 5
	icon_state = "adminlvl5"
	item_state = "Admin_ID"
	job_access_type = /datum/job/captain
	rank = "Карта доступа 5 административного уровня"
	assignment = "Карта доступа 5 административного уровня"
	class = CLASS_A

/obj/item/card/id/facilitydir
	name = "site director ID"
	desc = "A black ID. Looks like the person wearing this won't give it up easy."
	access_level = 5
	icon_state = "adminlvl5"
	item_state = "Admin_ID"
	job_access_type = /datum/job/captain
	rank = "Директор Зоны"
	assignment = "Директор Зоны"
	class = CLASS_A

/obj/item/card/id/tribunal
	name = "internal tribunal officer ID"
	desc = "A purple ID. Looks like the person wearing this won't give it up easy."
	access_level = 5
	icon_state = "tribunal"
	item_state = "tribunal"
	job_access_type = /datum/job/captain
	rank = "Офицер Внутреннего Трибунала"
	assignment = "Офицер Внутреннего Трибунала"
	class = CLASS_A

/obj/item/card/id/ethics
	name = "ethics committee liasion ID"
	desc = "A green ID. Looks like the person wearing this won't give it up easy."
	access_level = 5
	icon_state = "ethics"
	item_state = "ethics"
	rank = "Представитель Комитета по Этике"
	assignment = "Представитель Комитета по Этике"
	job_access_type = /datum/job/captain
	class = CLASS_A

// ERT CARDS

/obj/item/card/id/mtf
	name = "mobile task force ID"
	desc = "A black ID. Looks like the person wearing this won't give it up easy."
	access_level = 5
	icon_state = "adminlvl5"
	item_state = "Admin_ID"
	class = CLASS_A

/obj/item/card/id/mtf/ninetail
	name = "mobile task force ID"
	desc = "A black ID. Looks like the person wearing this won't give it up easy."
	assignment = "Epsilon-11 Task Force Operative"


/obj/item/card/id/mtf/ninetaillead
	name = "mobile task force ID"
	desc = "A black ID. Looks like the person wearing this won't give it up easy."
	assignment = "Epsilon-11 Task Force Leader"

/obj/item/card/id/mtf/epsilon
	name = "mobile task force ID"
	desc = "A black ID. Looks like the person wearing this won't give it up easy."
	assignment = "Epsilon-9 Task Force Operative"

/obj/item/card/id/mtf/nu_7
	name = "mobile task force ID"
	desc = "A black ID. Looks like the person wearing this won't give it up easy."
	assignment = "Nu-7 Task Force Operative"

/obj/item/card/id/mtf/beta_7
	name = "mobile task force ID"
	desc = "A black ID. Looks like the person wearing this won't give it up easy."
	assignment = "Beta-7 Task Force Operative"

/obj/item/card/id/mtf/alpha
	name = "mobile task force ID"
	desc = "A black ID. Looks like the person wearing this won't give it up easy."
	assignment = "Alpha-1 Task Force Operative"

/obj/item/card/id/mtf/omega
	name = "mobile task force ID"
	desc = "A black ID. Looks like the person wearing this won't give it up easy."
	assignment = "Omega-1 Task Force Operative"

/obj/item/card/id/mtf/isd
	name = "internal security operations ID"
	desc = "A black ID. Looks like the person wearing this won't give it up easy."
	assignment = "Internal Security Agent"

/obj/item/card/id/mtf/o5rep
	name = "central council command ID"
	desc = "A black ID. Looks like the person wearing this won't give it up easy."
	assignment = "O5 Representative"
	icon_state = "o5"
	item_state = "o5"

/obj/item/card/id/mtf/Initialize()
	. = ..()
	rank = "Mobile Task Force Operative"
	access |= get_all_site_access()

/obj/item/card/id/mtf/ninetaillead/Initialize()
	. = ..()
	rank = "Mobile Task Force Leader"
	access |= get_all_site_access()

/obj/item/card/id/physics
	name = "UNGOC military ID"
	desc = "A blue UNGOC ID. Looks like the person wearing this won't give it up easy."
	access_level = 5
	icon_state = "goc"
	item_state = "goc"
	assignment = "UNGOC Physics Operative"

/obj/item/card/id/physics/Initialize()
	. = ..()
	rank = "UNGOC Physics Operative"
	access |= get_all_station_access()

// COMMS CARDS

/obj/item/card/id/commslvl1
	name = "administration ID"
	desc = "A black ID. A black ID. Looks like the person wearing this won't give it up easy."
	access_level = 1
	//job_access_type = /datum/job/commeng
	icon_state = "adminlvl1"
	item_state = "Admin_ID"

/obj/item/card/id/commslvl4
	name = "administration ID"
	desc = "A black ID. A black ID. Looks like the person wearing this won't give it up easy."
	access_level = 4
	job_access_type = /datum/job/commsofficer
	icon_state = "adminlvl4"
	item_state = "Admin_ID"
	class = CLASS_B

// MEDICAL CARDS

/obj/item/card/id/medicintern
	name = "medical intern ID"
	desc = "A light blue card. Seems almost as unimportant as the person itself."
	access_level = 1
	icon_state = "securitylvl1"
	item_state = "Sec_ID1"
	job_access_type = /datum/job/medicaldoctor

/obj/item/card/id/emt
	name = "emt ID"
	desc = "A light blue card. Seems almost as unimportant as the person itself."
	access_level = 1
	icon_state = "securitylvl1"
	item_state = "Sec_ID1"
	job_access_type = /datum/job/emt

/obj/item/card/id/chemist
	name = "chemist ID"
	desc = "A light blue card. Seems almost as unimportant as the person itself."
	access_level = 2
	icon_state = "securitylvl2"
	item_state = "Sec_ID2"
	job_access_type = /datum/job/chemist

/obj/item/card/id/doctor
	name = "medical ID"
	desc = "A light blue card. Seems almost as unimportant as the person itself."
	access_level = 2
	icon_state = "securitylvl2"
	item_state = "Sec_ID2"
	job_access_type = /datum/job/medicaldoctor

/obj/item/card/id/chiefmedicalofficer
	name = "medical director ID"
	desc = "A dark purple ID. Looks important."
	access_level = 5
	icon_state = "securitylvl5"
	item_state = "Sec_ID5"
	job_access_type = /datum/job/cmo
	class = CLASS_A

/obj/item/card/id/assistantmedicalofficer
	name = "assistant medical officer ID"
	desc = "A purple ID. Seems important."
	access_level = 4
	icon_state = "securitylvl4"
	item_state = "Sec_ID4"
	//job_access_type = /datum/job/acmo
	class = CLASS_A

/obj/item/card/id/psychiatrist
	name = "psychiatrist ID"
	desc = "A light blue card. Seems important."
	access_level = 3
	icon_state = "adminlvl3"
	item_state = "Admin_ID"
	job_access_type = /datum/job/psychiatrist

// RESEARCH

/obj/item/card/id/rd
	name = "research director ID"
	desc = "A red ID. Looks like the person wearing this won't give it up easy."
	access_level = 5
	icon_state = "sciencelvl5"
	item_state = "Science_ID5"
	job_access_type = /datum/job/rd
	class = CLASS_A

// MISC

/obj/item/card/id/chef
	name = "chef ID"
	desc = "A light blue ID. Haven't you seen a janitor with this before?"
	access_level = 1
	icon_state = "sciencelvl1"
	item_state = "Science_ID1"
	job_access_type = /datum/job/chef

/obj/item/card/id/janitor
	name = "janitor ID"
	desc = "A purple ID. Haven't you seen a janitor with this before?"
	access_level = 1
	icon_state = "janitor"
	item_state = "janitor"
	job_access_type = /datum/job/janitor

/obj/item/card/id/bartender
	name = "bartender ID"
	desc = "A light blue ID. Haven't you seen a janitor with this before?"
	access_level = 1
	icon_state = "sciencelvl1"
	item_state = "Science_ID1"
	job_access_type = /datum/job/bartender

/obj/item/card/id/officeworker
	name = "Office Staff ID"
	desc = "A low level ID issued to office workers."
	access_level = 1
	icon_state = "officeworker"
	item_state = "officeworker"
	job_access_type = /datum/job/officeworker

/obj/item/card/id/classd
	name = "Class-D ID"
	desc = "An ID card issued to Class-D Foundation personnel."
	access_level = 0
	icon_state = "classd"
	item_state = "Admin_ID"
	job_access_type = /datum/job/classd
	class = CLASS_D

// LOGISTICS

/obj/item/card/id/logoff
	name = "logistic officer ID"
	desc = "A dark yellow ID. Looks cool, the person wearing it, not so much."
	icon_state = "sciencelvl3"
	item_state = "Science_ID3"
	job_access_type = /datum/job/qm
	class = CLASS_B


/obj/item/card/id/logspec
	name = "logistic specialist ID"
	desc = "A bright yellow ID. Looks ordinary?"
	icon_state = "sciencelvl2"
	item_state = "Science_ID2"
	job_access_type = /datum/job/cargo_tech

// CD ASSIGNMENT CARDS

/obj/item/card/id/dassignment
	desc = "A plain ID Card, used for granting access to D-Class personnel so they're able to perform their duties."
	class = CLASS_D
	access_level = 0

/obj/item/card/id/dassignment/dmining
	name = "mining assignment card"
	access = list(ACCESS_DCLASS_MINING)
	rank = "Шахтёр"
	assignment = "Шахтёр"
	icon_state = "classdmine"
	item_state = "classdmine"

/obj/item/card/id/dassignment/dbotany
	name = "botany assignment card"
	access = list(ACCESS_DCLASS_BOTANY)
	rank = "Ботаник"
	assignment = "Ботаник"
	icon_state = "classdbot"
	item_state = "classdbot"

/obj/item/card/id/dassignment/dkitchen
	name = "kitchen assignment card"
	access = list(ACCESS_DCLASS_KITCHEN)
	rank = "Повар"
	assignment = "Повар"
	icon_state = "classdcook"
	item_state = "classdcook"

/obj/item/card/id/dassignment/djanitorial
	name = "janitorial assignment card"
	access = list(ACCESS_DCLASS_JANITORIAL)
	rank = "Уборщик"
	assignment = "Уборщик"
	icon_state = "classdjan"
	item_state = "classdjan"

/obj/item/card/id/dassignment/dmedical
	name = "medical assignment card"
	access = list(ACCESS_DCLASS_MEDICAL)
	rank = "Медицинский работник"
	assignment = "Медицинский работник"
	icon_state = "classdmed"
	item_state = "classdmed"

/obj/item/card/id/dassignment/dluxury
	name = "luxury reward card"
	rank = "Люкс"
	assignment = "Люкс"
	access = list(ACCESS_DCLASS_LUXURY)

/obj/item/card/id/chaos
	name = "stolen ID"
	desc = "A green ID card, it's drawn on with black ink saying \"C.I.\", it's also got a crudely painted Chaos Insurgency logo over the SCP Logo, and an X marked over the SCP slogan, whoever's wearing this must be scary."
	icon_state = "ci"
	item_state = "ci"
	class = CLASS_CI
	access = list(ACCESS_ENGINEERING_LVL1, ACCESS_SYNDICATE)
	access_level = 5

/obj/item/card/id/chaos/lead
	name = "stolen administrative ID"
	desc = "A golden ID card mostly used by administrative staff, it's drawn on professionally with white ink saying \"C.I.\", it's also got a crudely painted Chaos Insurgency logo over the SCP Logo, and an aggressively red X marked over the SCP slogan, whoever's wearing this must be scary."
	icon_state = "cilead"
	item_state = "cilead"
	class = CLASS_CI
	access = list(ACCESS_ENGINEERING_LVL1, ACCESS_ADMIN_LVL1, ACCESS_SYNDICATE)
// Admin IDs
/obj/item/card/id/mtf/specops_officer
	name = "Crisis Center Officer ID"
	desc = "ID of someone whose power is way higher than yours."
	access_level = 5
	icon_state = "adminlvl5"
	assignment = "Crisis Center Officer"
	class = CLASS_A

/obj/item/card/id/mtf/specops_officer/New()
	access = get_access_ids()
	..()

/obj/item/card/id/mtf/site_auditor
	name = "Site auditor ID"
	desc = "ID of someone whose power is way higher than yours."
	access_level = 5
	icon_state = "adminlvl5"
	assignment = "Site auditor"
	detail_color = COLOR_COMMAND_BLUE
	extra_details = list("goldstripe")
	class = CLASS_A

/obj/item/card/id/mtf/site_auditor/New()
	access = get_access_ids()
	..()
