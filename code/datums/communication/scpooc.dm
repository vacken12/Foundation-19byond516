#define SPAN_SCPOOC(target, X) SPAN_CLASS("ooc","<span class='scpooc'>[create_text_tag("scpooc", "SCP-OOC:", target)] [X]</span>")


/decl/communication_channel/scpooc
	name = "SCPOOC"
	config_setting = "scpooc_allowed"
	expected_communicator_type = /client
	flags = COMMUNICATION_LOG_CHANNEL_NAME|COMMUNICATION_ADMIN_FOLLOW
	log_proc = GLOBAL_PROC_REF(log_ooc)
	mute_setting = MUTE_SCPOOC
	show_preference_setting = /datum/client_preference/show_scpooc


/decl/communication_channel/scpooc/can_communicate(client/C, message)
	. = ..()
	if(!.)
		return
	if(check_rights(R_ADMIN|R_MOD))
		return
	if(isghost(C.mob))
		to_chat(src, SPAN_WARNING("You cannot use [name] while ghosting/observing!"))
		return FALSE


/decl/communication_channel/scpooc/do_communicate(client/C, message)
	var/datum/admins/holder = C.holder

	for(var/client/target in GLOB.clients)
		if(check_rights(R_ADMIN|R_MOD, FALSE, target))
			receive_communication(C, target, SPAN_SCPOOC(target, "<EM>[get_options_bar(C, 0, 1, 1)]:</EM> <span class='message linkify'>[message]</span>"))
		else if(target.mob)
			var/display_name = C.key
			var/player_display = holder ? "[display_name]([usr.client.holder.rank])" : display_name
			receive_communication(C, target, SPAN_SCPOOC(target, "<EM>[player_display]:</EM> <span class='message linkify'>[message]</span>"))


/decl/communication_channel/scpooc/do_broadcast(message)
	for (var/client/target in GLOB.clients)
		if (check_rights(R_ADMIN|R_MOD, FALSE, target))
			receive_broadcast(target, SPAN_SCPOOC(target, "<strong>SYSTEM BROADCAST:</strong> <span class='message linkify'>[message]</span>"))

/client/proc/scpooc(msg as text)
	set category = "OOC"
	set name = "SCP-OOC"
	set desc = "SCP OOC"

	sanitize_and_communicate(/decl/communication_channel/scpooc, src, msg)
