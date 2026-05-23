// Глобальная переменная для текущего активного отряда (используется JoinResponseTeam)
var/global/datum/antagonist/mtf/active_ert = null

/client/proc/response_team()
	set name = "Dispatch Mobile Task Force"
	set category = "Special Verbs"
	set desc = "Send an MTF squad"

	if(!holder)
		to_chat(usr, SPAN_DANGER("Only administrators may use this command."))
		return
	if(GAME_STATE < RUNLEVEL_GAME)
		to_chat(usr, SPAN_DANGER("The game hasn't started yet!"))
		return
	if(send_emergency_team)
		to_chat(usr, SPAN_DANGER("[GLOB.using_map.boss_name] is already currently dispatching an MTF!"))
		return
	if(alert("Do you want to dispatch an MTF?",,"Yes","No") != "Yes")
		return

	var/list/available_mtfs = list(
		"Epsilon-11 (Nine-Tailed Fox)" = GLOB.mtf_epsilon_11,
		"Nu-7 (Hammer Down)" = GLOB.mtf_nu_7,
		"Beta-7 (Maz Hatters)" = GLOB.mtf_beta_7,
		"Eta-10 (See No Evil)" = GLOB.mtf_eta_10,
		"Alpha-1 (Red Right Hand)" = GLOB.mtf_alpha_1,
		"Omega-1 (Law's Left Hand)" = GLOB.mtf_omega_1,
		"Epsilon-9 (Fire Eaters)" = GLOB.mtf_epsilon_9,
		"ISD (Internal Security)" = GLOB.mtf_isd,
		"O5 Representative" = GLOB.mtf_o5rep
	)
	var/chosen = input("Which Mobile Task Force would you like to dispatch?") as null|anything in available_mtfs
	if(!chosen)
		return
	var/datum/antagonist/mtf/selected = available_mtfs[chosen]

	var/decl/security_state/security_state = decls_repository.get_decl(GLOB.using_map.security_state)
	if(security_state.current_security_level_is_lower_than(security_state.severe_security_level))
		switch(alert("Current security level lower than [security_state.severe_security_level.name]. Do you still want to dispatch this team?",,"Yes","No"))
			if("No")
				return

	var/reason = input("What is the reason for dispatching this MTF?", "Dispatching MTF") as text|null

	if(!reason && alert("You did not input a reason. Continue anyway?",,"Yes", "No") != "Yes")
		return

	if(send_emergency_team)
		to_chat(usr, SPAN_DANGER("Looks like someone beat you to it!"))
		return

	if(reason)
		message_staff("[key_name_admin(usr)] is dispatching the [selected.role_text] for the reason: [reason]", 1)
	else
		message_staff("[key_name_admin(usr)] is dispatching the [selected.role_text].", 1)

	log_admin("[key_name(usr)] used Dispatch MTF for [selected.role_text].")
	trigger_armed_response_team(selected, reason)

/proc/trigger_armed_response_team(datum/antagonist/mtf/team, reason = "")
	if(send_emergency_team)
		return

	// Принудительно заполняем точки спавна (если вдруг не инициализировано)
	if(!team.starting_locations || !team.starting_locations.len)
		team.get_starting_locations()

	command_announcement.Announce(replacetext(team.ert_announce_text, "%STATION%", station_name()), "[GLOB.using_map.boss_name]", team.ert_announce_sound)

	team.reason = reason
	active_ert = team

	send_emergency_team = 1
	for(var/mob/M in GLOB.player_list)
		if(isghost(M) || isnewplayer(M))
			M.throw_alert(ALERT_MTF, /atom/movable/screen/alert/mtf)

	sleep(600 * 5)   // 5 минут на сбор

	for(var/mob/M in GLOB.player_list)
		if(isghost(M) || isnewplayer(M))
			M.clear_alert(ALERT_MTF)
	send_emergency_team = 0
	active_ert = null

/client/verb/JoinResponseTeam()
	set name = "Join MTF Squad"
	set category = "OOC"

	if(!MayRespawn(1))
		to_chat(usr, SPAN_WARNING("You cannot join the response team at this time."))
		return

	if(isghost(usr) || isnewplayer(usr))
		if(!send_emergency_team || !active_ert)
			to_chat(usr, "No MTF is currently being sent.")
			return
		if(jobban_isbanned(usr, MODE_ERT) || jobban_isbanned(usr, "Security Officer"))
			to_chat(usr, SPAN_DANGER("You are jobbanned from the MTF!"))
			return
		if(active_ert.current_antagonists.len >= active_ert.hard_cap)
			to_chat(usr, "The MTF is already full!")
			return
		// Гарантируем наличие точек спавна на момент присоединения
		if(!active_ert.starting_locations || !active_ert.starting_locations.len)
			active_ert.get_starting_locations()
		active_ert.create_default(usr)
	else
		to_chat(usr, "You need to be an observer or new player to use this.")
