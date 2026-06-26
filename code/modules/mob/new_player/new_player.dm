/mob/new_player
	universal_speak = TRUE
	invisibility = 101
	density = FALSE
	stat = DEAD
	movement_handlers = list()
	anchored = TRUE	//  don't get pushed around
	virtual_mob = null // Hear no evil, speak no evil

	var/ready = 0
	var/respawned_time = 0
	//Referenced when you want to delete the new_player later on in the code.
	var/spawning = 0
	///Player counts for the Lobby tab
	var/totalPlayers = 0
	var/totalPlayersReady = 0
	var/show_invalid_jobs = 0

/mob/new_player/Initialize()
	add_verb(src, /mob/proc/toggle_antag_pool)
	if(length(GLOB.new_player))
		forceMove(pick(GLOB.new_player))
	return ..()

/mob/new_player/get_status_tab_items()
	.=..()
	if(check_rights(R_ADMIN|R_MOD, 0, src))
		. += "Game Mode: [SSticker.mode ? SSticker.mode.name : SSticker.master_mode] ([SSticker.master_mode])"
		var/extra_antags = list2params(additional_antag_types)
		. += "Added Antagonists: [extra_antags ? extra_antags : "None"]"
	else
		. += "Game Mode: [PUBLIC_GAME_MODE]"

	. += "Initial Continue Vote: [round(config.vote_autotransfer_initial / 600, 1)] minutes"
	. += "Additional Vote Every: [round(config.vote_autotransfer_interval / 600, 1)] minutes"

	if(SSticker.HasRoundStarted())
		. += "Next Continue Vote: [max(round(transfer_controller.time_till_transfer_vote() / 600, 1), 0)] minutes"
		return

	. += "Time To Start: [round(SSticker.pregame_timeleft/10)][SSticker.round_progressing ? "" : " (DELAYED)"]"
	. += "Players: [totalPlayers]"
	. += "Players Ready: [totalPlayersReady]"
	totalPlayers = 0
	totalPlayersReady = 0
	for(var/mob/new_player/player in GLOB.player_list)
		var/highjob
		if(player.client)
			var/show_ready = player.client.get_preference_value(/datum/client_preference/show_ready) == GLOB.PREF_SHOW
			if(player.client.prefs?.job_high)
				highjob = " as [player.client.prefs.job_high]"
			if(!player.is_stealthed())
				. += "[player.key] [(player.ready && show_ready) ? "Playing[highjob]" : null]"
		totalPlayers++
		if(player.ready)
			totalPlayersReady++

/mob/new_player/Topic(href, href_list) // This is a full override; does not call parent.
	if(usr != src)
		return TOPIC_NOACTION
	if(!client)
		return TOPIC_NOACTION

	if(href_list["SelectedJob"])
		var/datum/job/job = SSjobs.get_by_title(href_list["SelectedJob"])

		if(!SSjobs.check_general_join_blockers(src, job))
			return FALSE

		var/datum/species/S = all_species[client.prefs.species]
		if(!check_species_allowed(S))
			return FALSE

		if(client.prefs.organ_data[BP_CHEST] == "cyborg")
			if(!whitelist_lookup(SPECIES_FBP, client.ckey) && client.prefs.species != SPECIES_IPC)
				tgui_alert(client, "You are currently not whitelisted to play as FBP.", null, list("Ok"))
				return FALSE

		var/should_warn = TRUE
		if(client.prefs.job_high == job.title)
			should_warn = FALSE
		else if(job.title in client.prefs.job_medium)
			should_warn = FALSE
		else if(job.title in client.prefs.job_low)
			should_warn = FALSE
		else if(job.is_restricted(client.prefs))
			should_warn = FALSE // If it isn't available there will be its own message.

		if(should_warn)
			if(tgui_alert(client, "You don't have any preferences set for [job.title]. Are you sure you want to join as it?", "Confirm Job Selection", list("Yes", "No")) != "Yes")
				return FALSE

		AttemptLateSpawn(job, client.prefs.spawnpoint)
		return

	if(href_list["invalid_jobs"])
		show_invalid_jobs = !show_invalid_jobs
		LateChoices() // Update the window

	if(!ready && href_list["preference"])
		if(client)
			client.prefs.process_link(src, href_list)

/mob/new_player/proc/AttemptLateSpawn(datum/job/job, spawning_at)
	if(src != usr)
		return FALSE
	if(GAME_STATE != RUNLEVEL_GAME)
		to_chat(usr, SPAN_WARNING("The round is either not ready, or has already finished..."))
		return FALSE
	if(!config.enter_allowed)
		to_chat(usr, SPAN_NOTICE("There is an administrative lock on entering the game!"))
		return FALSE

	if(!job || !job.is_available(client))
		tgui_alert(client, "[job.title] is not available. Please try another.", null, list("Ok"))
		return FALSE
	if(job.is_restricted(client.prefs, src))
		return

	var/datum/spawnpoint/spawnpoint = job.get_spawnpoint(client)
	var/turf/spawn_turf = pick(spawnpoint.turfs)
	if(job.latejoin_at_spawnpoints)
		var/obj/S = job.get_roundstart_spawnpoint()
		spawn_turf = get_turf(S)

	if(!SSjobs.check_unsafe_spawn(src, spawn_turf))
		return

	// Just in case someone stole our position while we were waiting for input from alert() proc
	if(!job || !job.is_available(client))
		tgui_alert(client, "[job.title] is not available. Please try another.", null, list("Ok"))
		return FALSE

	SSjobs.assign_role(src, job.title, 1)

	var/mob/living/character = create_character(spawn_turf)	//creates the human and transfers vars and mind
	if(!character)
		return FALSE

	character = SSjobs.equip_rank(character, job.title, 1)					//equips the human

	// AIs don't need a spawnpoint, they must spawn at an empty core
	if(character.mind.assigned_role == "ИИ")

		character = character.AIize(move = FALSE) // AIize the character, but don't move them yet

		// is_available for AI checks that there is an empty core available in this list
		var/obj/structure/AIcore/deactivated/C = empty_playable_ai_cores[1]
		empty_playable_ai_cores -= C

		character.forceMove(C.loc)
		var/mob/living/silicon/ai/A = character
		A.on_mob_init()
		A.client.init_verbs()

		AnnounceCyborg(character, job.title, "has been downloaded to the empty core in \the [character.loc.loc]")
		SSticker.mode.handle_latejoin(character)

		qdel(C)
		qdel(src)
		return

	SSticker.mode.handle_latejoin(character)
	GLOB.universe.OnPlayerLatejoin(character)
	spawnpoint.after_join(character)
	character.client.init_verbs()
	if(job.create_record)
		if(character.mind.assigned_role != "Robot")
			character.CreateModularRecord()
			SSticker.minds += character.mind//Cyborgs and AIs handle this in the transform proc.	//TODO!!!!! ~Carn
			AnnounceArrival(character, job, spawnpoint.msg)
		else
			AnnounceCyborg(character, job, spawnpoint.msg)
	log_and_message_staff("has joined the round as [character.mind.assigned_role][character.mind.role_alt_title == character.mind.assigned_role ? "" : " ([character.mind.role_alt_title])"].", character)

	if(character.needs_wheelchair())
		equip_wheelchair(character)

	qdel(src)

/mob/new_player/proc/AnnounceCyborg(mob/living/character, rank, join_message)
	if(GAME_STATE == RUNLEVEL_GAME)
		if(character.mind.role_alt_title)
			rank = character.mind.role_alt_title
		// can't use their name here, since cyborg namepicking is done post-spawn, so we'll just say "A new Cyborg has arrived"/"A new Android has arrived"/etc.
		GLOB.global_announcer.autosay("A new[rank ? " [rank]" : " visitor" ] [join_message ? join_message : "has arrived"].", "Arrivals Announcement Computer")

/mob/new_player/proc/LateChoices()
	var/name = client.prefs.be_random_name ? "friend" : client.prefs.real_name

	// Build CSS separately to avoid brace conflicts with DM string parsing
	var/css = "<style>"
	css += "@keyframes fadeIn{from{opacity:0;transform:translateY(10px)}to{opacity:1;transform:translateY(0)}}"
	css += "@keyframes pulseGlow{0%,100%{box-shadow:0 0 8px rgba(100,150,255,0.1)}50%{box-shadow:0 0 16px rgba(100,150,255,0.25)}}"
	css += "@keyframes shimmer{0%{background-position:-200% center}100%{background-position:200% center}}"
	css += "@keyframes slideDown{from{opacity:0;transform:translateY(-8px)}to{opacity:1;transform:translateY(0)}}"
	css += "body{background:linear-gradient(160deg,#0b0f1c 0%,#111827 40%,#0f1929 100%);font-family:'Segoe UI','Roboto',Arial,sans-serif;color:#c8d0e0;margin:0;padding:16px;min-height:100vh;position:relative;overflow-x:hidden;}"
	css += "body::before{content:'';position:fixed;top:0;left:0;right:0;bottom:0;background:radial-gradient(ellipse at 50% 0%,rgba(60,100,180,0.06) 0%,transparent 60%);pointer-events:none;z-index:0;}"
	css += "body > *{position:relative;z-index:1;}"
	css += ".welcome-header{text-align:center;padding:20px 24px;background:linear-gradient(145deg,rgba(25,35,65,0.85),rgba(20,30,55,0.9));border:1px solid rgba(60,80,130,0.3);border-radius:12px;margin-bottom:14px;box-shadow:0 4px 20px rgba(0,0,0,0.3),inset 0 1px 0 rgba(100,140,220,0.1);backdrop-filter:blur(10px);animation:fadeIn 0.4s ease-out;}"
	css += ".welcome-header .greeting{font-size:22px;font-weight:600;color:#e8edf5;text-shadow:0 2px 6px rgba(0,0,0,0.5);letter-spacing:0.3px;}"
	css += ".welcome-header .greeting::before{content:'✦ ';color:#6a8fd8;font-weight:300;}"
	css += ".welcome-header .greeting::after{content:' ✦';color:#6a8fd8;font-weight:300;}"
	css += ".welcome-header .subtitle{font-size:12px;color:#7a8aaa;margin-top:6px;letter-spacing:0.5px;}"
	css += ".welcome-header .subtitle::before{content:'⏱ ';color:#5a7aaa;}"
	css += ".evacuation-banner{text-align:center;padding:12px 18px;background:linear-gradient(145deg,rgba(50,10,10,0.85),rgba(80,18,18,0.9));border:1px solid rgba(180,40,40,0.4);border-radius:10px;margin-bottom:14px;color:#ff6b6b;font-weight:600;font-size:13px;box-shadow:0 2px 16px rgba(200,0,0,0.12),inset 0 1px 0 rgba(255,80,80,0.1);animation:fadeIn 0.5s ease-out, pulseGlow 3s ease-in-out infinite;letter-spacing:0.3px;backdrop-filter:blur(6px);}"
	css += ".evacuation-banner::before{content:'⚠ ';font-size:15px;}"
	css += ".controls-bar{text-align:center;padding:8px;margin-bottom:14px;animation:fadeIn 0.5s ease-out 0.1s both;}"
	css += ".controls-bar a{display:inline-block;padding:9px 22px;background:linear-gradient(145deg,rgba(35,50,80,0.7),rgba(45,60,95,0.8));color:#b0c8e8;border:1px solid rgba(65,85,130,0.35);border-radius:8px;text-decoration:none;font-size:12px;font-weight:500;transition:all 0.25s ease;letter-spacing:0.5px;backdrop-filter:blur(4px);}"
	css += ".controls-bar a:hover{background:linear-gradient(145deg,rgba(50,70,110,0.8),rgba(60,85,130,0.9));color:#fff;border-color:rgba(100,140,220,0.5);box-shadow:0 4px 16px rgba(60,100,200,0.2),inset 0 1px 0 rgba(140,180,255,0.15);transform:translateY(-1px);}"
	css += ".station-header{text-align:center;padding:16px 20px;background:linear-gradient(145deg,rgba(25,38,65,0.85),rgba(30,48,80,0.9));border:1px solid rgba(60,90,150,0.3);border-radius:10px;margin-bottom:14px;font-size:15px;font-weight:600;color:#80b0ff;text-transform:uppercase;letter-spacing:3px;text-shadow:0 1px 6px rgba(40,80,200,0.2);box-shadow:0 4px 16px rgba(0,0,0,0.25),inset 0 1px 0 rgba(100,150,255,0.1);backdrop-filter:blur(8px);animation:fadeIn 0.5s ease-out 0.15s both;}"
	css += ".station-header::before{content:'◈ ';color:#5a8ace;}"
	css += ".station-header::after{content:' ◈';color:#5a8ace;}"
	css += ".jobs-table{width:100%;border-collapse:separate;border-spacing:0 5px;animation:fadeIn 0.6s ease-out 0.2s both;}"
	css += ".department-header{padding:10px 16px;background:linear-gradient(145deg,rgba(25,35,60,0.8),rgba(30,42,70,0.85));border:1px solid rgba(60,80,130,0.25);border-radius:8px;text-align:center;font-weight:600;font-size:13px;color:#b8cce8;text-transform:uppercase;letter-spacing:2px;box-shadow:0 2px 8px rgba(0,0,0,0.2),inset 0 1px 0 rgba(100,140,220,0.08);backdrop-filter:blur(4px);}"
	css += ".department-header:hover{animation:shimmer 1.5s ease-in-out;background:linear-gradient(145deg,rgba(30,42,72,0.85),rgba(35,50,80,0.9));}"
	css += ".job-row{padding:5px 10px;background:rgba(18,24,40,0.5);border-radius:6px;transition:all 0.2s ease;border:1px solid transparent;}"
	css += ".job-row:hover{background:rgba(28,38,60,0.7);border-color:rgba(80,120,200,0.2);box-shadow:0 2px 10px rgba(0,0,0,0.15);transform:translateX(2px);}"
	css += ".job-row a{color:#88b4e8;text-decoration:none;font-size:12px;padding:6px 10px;display:block;border-radius:5px;transition:all 0.2s ease;text-shadow:0 1px 2px rgba(0,0,0,0.3);}"
	css += ".job-row a:hover{color:#b0d4ff;background:rgba(50,75,130,0.3);padding-left:16px;text-shadow:0 0 8px rgba(100,160,255,0.2);}"
	css += ".submap-header{padding:10px 16px;background:linear-gradient(145deg,rgba(20,38,25,0.8),rgba(25,48,32,0.85));border:1px solid rgba(50,110,60,0.25);border-radius:8px;text-align:center;font-weight:600;font-size:12px;color:#8bca8b;text-transform:uppercase;letter-spacing:2px;margin-top:8px;box-shadow:0 2px 8px rgba(0,0,0,0.2),inset 0 1px 0 rgba(80,180,80,0.08);backdrop-filter:blur(4px);}"
	css += ".submap-header::before{content:'◈ ';color:#6aaa6a;}"
	css += ".submap-header::after{content:' ◈';color:#6aaa6a;}"
	css += ".hidden-reasons{padding:14px 18px;background:rgba(40,32,18,0.6);border:1px solid rgba(140,120,40,0.25);border-radius:8px;margin-bottom:12px;font-size:11px;color:#b8a868;line-height:1.6;backdrop-filter:blur(4px);animation:slideDown 0.3s ease-out;}"
	css += ".hidden-reasons b{color:#d4b868;}"
	css += ".no-positions{text-align:center;padding:24px;color:#556688;font-style:italic;font-size:13px;letter-spacing:0.5px;}"
	css += "a{color:#88b4e8;}a:visited{color:#88b4e8;}"
	css += "::-webkit-scrollbar{width:8px;}"
	css += "::-webkit-scrollbar-track{background:rgba(15,20,35,0.5);border-radius:4px;}"
	css += "::-webkit-scrollbar-thumb{background:linear-gradient(180deg,rgba(60,80,130,0.4),rgba(80,100,160,0.5));border-radius:4px;}"
	css += "::-webkit-scrollbar-thumb:hover{background:linear-gradient(180deg,rgba(80,100,160,0.6),rgba(100,130,200,0.7));}"
	css += "</style>"

	var/list/header = list("<html><head>", css, "</head><body>")

	header += "<div class='welcome-header'>"
	header += "<div class='greeting'>Welcome, [name]</div>"
	header += "<div class='subtitle'>Round Duration: [DisplayTimeText(world.time - SSticker.round_start_time)]</div>"
	header += "</div>"

	if(evacuation_controller.has_evacuated())
		header += "<div class='evacuation-banner'>⚠ \The [station_name()] has been evacuated.</div>"
	else if(evacuation_controller.is_evacuating())
		if(evacuation_controller.emergency_evacuation)
			header += "<div class='evacuation-banner'>⚠ \The [station_name()] is currently undergoing evacuation procedures.</div>"
		else
			header += "<div class='evacuation-banner'>⚠ \The [station_name()] is currently undergoing crew transfer procedures.</div>"

	var/list/dat = list()
	dat += "<div class='controls-bar'>"
	dat += "<a href='byond://?src=\ref[src];invalid_jobs=1'>[show_invalid_jobs ? "✕ Hide" : "☰ Show"] unavailable jobs</a>"
	dat += "</div>"

	dat += "<div class='station-header'>❖ [GLOB.using_map.station_name] ❖</div>"

	dat += "<table class='jobs-table'>"
	// TORCH JOBS
	var/list/job_summaries = list()
	var/list/hidden_reasons = list()
	for(var/datum/job/job in SSjobs.primary_job_datums)
		var/summary = job.get_join_link(client, "byond://?src=\ref[src];SelectedJob=[job.title]", show_invalid_jobs)
		if(summary)
			var/summary_key = (job.department ? job.department : "No Department")
			var/list/existing_summaries = job_summaries[summary_key]
			if(!existing_summaries)
				existing_summaries = list()
				job_summaries[summary_key] = existing_summaries
			if(job.head_position)
				existing_summaries.Insert(1, summary)
			else
				existing_summaries.Add(summary)
		else
			for(var/raisin in job.get_unavailable_reasons(client))
				hidden_reasons[raisin] = TRUE

	var/added_job = FALSE
	if(length(job_summaries))
		for(var/job_category in job_summaries)
			if(length(job_summaries[job_category]))
				dat += "<tr><td class='department-header' colspan = 3>— [job_category] —</td></tr>"
				for(var/job_entry in job_summaries[job_category])
					dat += "<tr><td class='job-row' colspan = 3>[job_entry]</td></tr>"
				added_job = TRUE

	if(!added_job)
		dat += "<tr><td class='no-positions' colspan = 3>No available positions.</td></tr>"

	// SUBMAP JOBS
	for(var/thing in SSmapping.submaps)
		var/datum/submap/submap = thing
		if(submap && submap.available())
			dat += "<tr><td class='submap-header' colspan = 3>◈ [submap.name] ([submap.archetype.descriptor]) ◈</td></tr>"
			job_summaries = list()
			for(var/otherthing in submap.jobs)
				var/datum/job/job = submap.jobs[otherthing]
				var/summary = job.get_join_link(client, "byond://?src=\ref[submap];joining=\ref[src];join_as=[otherthing]", show_invalid_jobs)
				if(summary && summary != "")
					LAZYADD(job_summaries, summary)
				else
					for(var/raisin in job.get_unavailable_reasons(client))
						hidden_reasons[raisin] = TRUE

			if(LAZYLEN(job_summaries))
				for(var/job_entry in job_summaries)
					dat += "<tr><td class='job-row' colspan = 3>[job_entry]</td></tr>"
			else
				dat += "<tr><td class='no-positions' colspan = 3>No available positions.</td></tr>"

	dat += "</table></div>"

	if(LAZYLEN(hidden_reasons))
		var/list/additional_dat = list("<div class='hidden-reasons'><b>Some roles have been hidden from this list for the following reasons:</b><br>")
		for(var/raisin in hidden_reasons)
			additional_dat += "[raisin]<br>"
		additional_dat += "</div>"
		dat = additional_dat + dat

	dat = header + dat

	var/datum/browser/popup = new(src, "latechoices", "Choose Profession", 720, 800)
	popup.set_content(jointext(dat, null))
	popup.open(0)

/mob/new_player/proc/create_character(turf/spawn_turf)
	spawning = TRUE
	if(client.prefs.organ_data[BP_CHEST] == "cyborg")
		if(!whitelist_lookup(SPECIES_FBP, client.ckey) && client.prefs.species != SPECIES_IPC)
			tgui_alert(client, "You are currently not whitelisted to play as FBP.", null, list("Ok"))
			spawning = FALSE
			return
	close_spawn_windows()

	var/mob/living/carbon/human/new_character

	var/datum/species/chosen_species
	if(client.prefs.species)
		chosen_species = all_species[client.prefs.species]

	if(!spawn_turf)
		var/datum/job/job = SSjobs.get_by_title(mind.assigned_role)
		if(!job)
			job = SSjobs.get_by_title(GLOB.using_map.default_assistant_title)
		var/datum/spawnpoint/spawnpoint = job.get_spawnpoint(client, client.prefs.ranks[job.title])
		spawn_turf = pick(spawnpoint.turfs)

	if(chosen_species)
		if(!check_species_allowed(chosen_species))
			spawning = FALSE //abort
			return null
		new_character = new(spawn_turf, chosen_species.name)
		if(chosen_species.has_organ[BP_POSIBRAIN] && client && client.prefs.is_shackled)
			var/obj/item/organ/internal/posibrain/B = new_character.internal_organs_by_name[BP_POSIBRAIN]
			if(B)	B.shackle(client.prefs.get_lawset())

	if(!new_character)
		new_character = new(spawn_turf)

	new_character.lastarea = get_area(spawn_turf)

	client.prefs.copy_to(new_character)

	sound_to(src, sound(null, repeat = 0, wait = 0, volume = 85, channel = GLOB.lobby_sound_channel))// MAD JAMS cant last forever yo

	if(mind)
		mind.active = FALSE //we wish to transfer the key manually
		mind.original = new_character
		if(client.prefs.memory)
			mind.StoreMemory(client.prefs.memory)
		mind.transfer_to(new_character)					//won't transfer key since the mind is not active

	new_character.dna.ready_dna(new_character)
	new_character.dna.b_type = client.prefs.b_type
	new_character.sync_organ_dna()
	if(client.prefs.char_nearsighted)
		new_character.become_nearsighted(ROUNDSTART_TRAIT)

	// Do the initial caching of the player's body icons.
	new_character.force_update_limbs()
	new_character.update_eyes()
	new_character.regenerate_icons()

	new_character.key = key		//Manually transfer the key to log them in
	new_character.client.init_verbs()
	return new_character

/mob/new_player/proc/ViewManifest()
	var/dat = "<div align='center'>"
	dat += html_crew_manifest(OOC = 1)
	//show_browser(src, dat, "window=manifest;size=370x420;can_close=1")
	var/datum/browser/popup = new(src, "Crew Manifest", "Crew Manifest", 370, 420, src)
	popup.set_content(dat)
	popup.open()

/mob/new_player/Move()
	return FALSE

/mob/new_player/proc/close_spawn_windows()
	close_browser(src, "window=latechoices") //closes late choices window
	// Cone fix
	for(var/mob/M in GLOB.player_list)
		M.update_cone_size()
		M.reload_fullscreen()
		M.update_lighting_size()


/mob/new_player/proc/check_species_allowed(datum/species/S, show_alert = TRUE)
	if(!S.is_available_for_join() && !has_admin_rights())
		if(show_alert)
			tgui_alert(client, "Your current species, [client.prefs.species], is not available for play.", null, list("Ok"))
		return FALSE
	if(!is_alien_whitelisted(src, S))
		if(show_alert)
			tgui_alert(client, "You are currently not whitelisted to play [client.prefs.species].", null, list("Ok"))
		return FALSE
	return TRUE

/mob/new_player/get_species()
	var/datum/species/chosen_species
	if(client.prefs.species)
		chosen_species = all_species[client.prefs.species]

	if(!chosen_species || !check_species_allowed(chosen_species, 0))
		return SPECIES_HUMAN

	return chosen_species.name

/mob/new_player/get_gender()
	if(!client || !client.prefs)
		return ..()

	return client.prefs.gender

/mob/new_player/is_ready()
	return ready && ..()

/mob/new_player/hear_say(message, verb = "says", datum/language/language = null, alt_name = "",italics = 0, mob/speaker = null)
	return

/mob/new_player/hear_radio(message, verb="says", datum/language/language=null, part_a, part_b, part_c, mob/speaker = null, hard_to_hear = 0)
	return

/mob/new_player/show_message(msg, type, alt, alt_type)
	return

/mob/new_player/MayRespawn()
	return TRUE

/mob/new_player/touch_map_edge()
	return

/mob/new_player/say(message)
	sanitize_and_communicate(/decl/communication_channel/ooc, client, message)

/mob/new_player/verb/next_lobby_track() // for admin to all players in lobby
	set popup_menu = FALSE
	set name = "Play Different Lobby Track"
	set category = "Server"

	if(!check_rights(R_SERVER)) return

	SSstatistics.add_field_details("admin_verb","PDT") //Unique identifier
	log_and_message_staff("[src] changes lobby track.")

	var/list/available_tracks = subtypesof(/decl/audio/track)
	var/list/track_names = list()
	var/list/track_types = list()

	for(var/track_type in available_tracks)
		var/decl/audio/track/track = track_type
		if(track.title)
			track_names.Add("[track.title] - [track.author]")
			track_types.Add(track_type)

	var/selection = input(src, "Select a lobby track to play:", "Lobby Music", null) as null|anything in track_names
	if(!selection)
		return

	var/index = track_names.Find(selection)
	if(!index)
		return

	var/selected_track_type = track_types[index]
	var/decl/audio/track/selected_track = new selected_track_type()

	for(var/mob/new_player/N in GLOB.player_list)
		sound_to(N, sound(selected_track.source, repeat = 1, volume = 100, channel = GLOB.lobby_sound_channel))
		to_chat(world, selected_track.get_info())

/mob/new_player/verb/player_next_lobby_track() // for players in lobby
	set name = "Change Lobby Track"
	set category = "OOC"

	if(get_preference_value(/datum/client_preference/play_lobby_music) == GLOB.PREF_NO)
		return

	var/list/available_tracks = subtypesof(/decl/audio/track)
	var/list/track_names = list()
	var/list/track_types = list()

	for(var/track_type in available_tracks)
		var/decl/audio/track/track = track_type
		if(track.title)
			track_names.Add("[track.title] - [track.author]")
			track_types.Add(track_type)

	var/selection = input(src, "Select a lobby track to play:", "Lobby Music", null) as null|anything in track_names
	if(!selection)
		return

	var/index = track_names.Find(selection)

	if(!index)
		return

	var/selected_track_type = track_types[index]
	var/decl/audio/track/selected_track = new selected_track_type()

	sound_to(src, sound(selected_track.source, repeat = 1, volume = 100, channel = GLOB.lobby_sound_channel))
	to_chat(src, selected_track.get_info())
