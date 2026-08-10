var/global/send_chaos_team = 0
var/global/datum/antagonist/chaos/active_chaos = null

/client/proc/chaos_team()
	set name = "Dispatch Chaos Insurgents"
	set category = "Special Verbs"
	set desc = "Send Chaos Insurgents to the site"

	if(!holder)
		to_chat(usr, SPAN_DANGER("Only administrators may use this command."))
		return
	if(GAME_STATE < RUNLEVEL_GAME)
		to_chat(usr, SPAN_DANGER("The game hasn't started yet!"))
		return
	if(send_chaos_team)
		to_chat(usr, SPAN_DANGER("Chaos Insurgents are already being dispatched!"))
		return
	if(alert("Do you want to dispatch Chaos Insurgents?",,"Yes","No") != "Yes")
		return

	var/announce = (alert("Do you want to announce the Chaos dispatch to the station?", "Announce", "Yes", "No") == "Yes")

	var/reason = input("What is the reason for dispatching Chaos Insurgents?", "Dispatching Chaos") as text|null

	if(!reason && alert("You did not input a reason. Continue anyway?",,"Yes", "No") != "Yes")
		return

	if(send_chaos_team)
		to_chat(usr, SPAN_DANGER("Looks like someone beat you to it!"))
		return

	if(reason)
		message_staff("[key_name_admin(usr)] is dispatching Chaos Insurgents for the reason: [reason] ([announce ? "announced" : "silent"])", 1)
	else
		message_staff("[key_name_admin(usr)] is dispatching Chaos Insurgents. ([announce ? "announced" : "silent"])", 1)

	log_admin("[key_name(usr)] used Dispatch Chaos Insurgents.")
	trigger_chaos_team(reason, announce)

/proc/trigger_chaos_team(reason = "", announce = TRUE)
	if(send_chaos_team)
		return

	var/datum/antagonist/chaos/team = GLOB.chaos
	if(!team)
		return

	if(!team.starting_locations || !team.starting_locations.len)
		team.get_starting_locations()

	if(announce)
		command_announcement.Announce("WARNING. Suspicious activity detected in communications systems. Possible invasion of the facility is being prepared. It is recommended to strengthen perimeter security.", "SECURITY SYSTEM")

	team.reason = reason
	active_chaos = team
	send_chaos_team = 1

	for(var/mob/M in GLOB.player_list)
		if(isghost(M) || isnewplayer(M))
			M.throw_alert("chaos", /atom/movable/screen/alert/chaos)

	sleep(600 * 5)

	for(var/mob/M in GLOB.player_list)
		if(isghost(M) || isnewplayer(M))
			M.clear_alert("chaos")
	send_chaos_team = 0
	active_chaos = null

/client/verb/JoinChaosTeam()
	set name = "Join Chaos Insurgents"
	set category = "OOC"

	if(!MayRespawn(1))
		to_chat(usr, SPAN_WARNING("You cannot join the Chaos Insurgents at this time."))
		return

	if(isghost(usr) || isnewplayer(usr))
		if(!send_chaos_team || !active_chaos)
			to_chat(usr, "No Chaos Insurgents are currently being dispatched.")
			return
		if(jobban_isbanned(usr, "Chaos Insurgent"))
			to_chat(usr, SPAN_DANGER("You are jobbanned from the Chaos Insurgents!"))
			return
		if(active_chaos.current_antagonists.len >= active_chaos.hard_cap)
			to_chat(usr, "The Chaos Insurgent team is already full!")
			return
		if(!active_chaos.starting_locations || !active_chaos.starting_locations.len)
			active_chaos.get_starting_locations()
		active_chaos.create_default(usr)
	else
		to_chat(usr, "You need to be an observer or new player to use this.")
