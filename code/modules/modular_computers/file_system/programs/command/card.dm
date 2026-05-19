/datum/computer_file/program/card_mod
	filename = "cardmod"
	filedesc = "ID card modification program"
	nanomodule_path = /datum/nano_module/program/card_mod
	program_icon_state = "id"
	program_key_state = "id_key"
	program_menu_icon = "id-card"
	extended_desc = "Program for programming crew ID cards."
	requires_ntnet = FALSE
	size = 8
	/// Bitfield of access types this terminal is allowed to modify.
	var/operating_access_types = ACCESS_TYPE_NONE | ACCESS_TYPE_STATION | ACCESS_TYPE_CENTCOM | ACCESS_TYPE_INNATE | ACCESS_TYPE_CONTAINMENT | ACCESS_TYPE_UNGOC

/datum/nano_module/program/card_mod
	name = "ID card modification program"
	var/mod_mode = 1
	var/is_centcom = 0
	var/show_assignments = 0

/datum/nano_module/program/card_mod/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = 1, datum/topic_state/state = GLOB.default_state)
	var/list/data = host.initial_data()
	var/obj/item/stock_parts/computer/card_slot/card_slot = program.computer.card_slot

	data["src"] = "\ref[src]"
	data["station_name"] = station_name()
	data["manifest"] = html_crew_manifest()
	data["assignments"] = show_assignments
	data["have_id_slot"] = !!card_slot
	data["have_printer"] = program.computer.nano_printer
	data["authenticated"] = program.program_has_access(user)
	if(!data["have_id_slot"] || !data["have_printer"])
		mod_mode = 0 //We can't modify IDs when there is no card reader
	if(card_slot)
		var/obj/item/card/id/id_card = card_slot.stored_card
		data["has_id"] = !!id_card
		data["id_account_number"] = id_card ? id_card.associated_account_number : null
		data["id_email_login"] = id_card ? id_card.associated_email_login["login"] : null
		data["id_email_password"] = id_card ? stars(id_card.associated_email_login["password"], 0) : null
		data["id_rank"] = id_card && id_card.assignment ? id_card.assignment : "Unassigned"
		data["id_owner"] = id_card && id_card.registered_name ? id_card.registered_name : "-----"
		data["id_name"] = id_card ? id_card.name : "-----"
	data["mmode"] = mod_mode
	data["centcom_access"] = is_centcom

	data["command_jobs"] = format_jobs(SSjobs.titles_by_department(COM))
	data["support_jobs"] = format_jobs(SSjobs.titles_by_department(SPT))
	data["engineering_jobs"] = format_jobs(SSjobs.titles_by_department(ENG))
	data["medical_jobs"] = format_jobs(SSjobs.titles_by_department(MED))
	data["science_jobs"] = format_jobs(SSjobs.titles_by_department(SCI))
	data["security_jobs"] = format_jobs(SSjobs.titles_by_department(SEC))
	data["exploration_jobs"] = format_jobs(SSjobs.titles_by_department(EXP))
	data["service_jobs"] = format_jobs(SSjobs.titles_by_department(SRV))
	data["supply_jobs"] = format_jobs(SSjobs.titles_by_department(SUP))
	data["civilian_jobs"] = format_jobs(SSjobs.titles_by_department(CIV))
	data["centcom_jobs"] = format_jobs(get_all_centcom_jobs())
	data["representative_jobs"] = format_jobs(SSjobs.titles_by_department(REP))

	data["all_centcom_access"] = is_centcom ? get_accesses(1) : null
	data["regions"] = get_accesses()

	if(card_slot && card_slot.stored_card)
		var/obj/item/card/id/id_card = card_slot.stored_card
		if(is_centcom)
			var/list/all_centcom_access = list()
			for(var/access in get_all_centcom_access())
				all_centcom_access.Add(list(list(
					"desc" = replacetext(get_centcom_access_desc(access), " ", "&nbsp"),
					"ref" = access,
					"allowed" = (access in id_card.access) ? 1 : 0)))
			data["all_centcom_access"] = all_centcom_access
		else
			var/list/regions = list()
			for(var/i = ACCESS_REGION_MIN; i <= ACCESS_REGION_MAX; i++)
				var/list/accesses = list()
				for(var/access in get_region_accesses(i))
					if (get_access_desc(access))
						accesses.Add(list(list(
							"desc" = replacetext(get_access_desc(access), " ", "&nbsp"),
							"ref" = access,
							"allowed" = (access in id_card.access) ? 1 : 0)))

				regions.Add(list(list(
					"name" = get_region_accesses_name(i),
					"accesses" = accesses)))
			data["regions"] = regions

	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		ui = new(user, src, ui_key, "identification_computer.tmpl", name, 600, 700, state = state)
		ui.auto_update_layout = 1
		ui.set_initial_data(data)
		ui.open()

/datum/nano_module/program/card_mod/proc/format_jobs(list/jobs)
	var/obj/item/card/id/id_card = program.computer.card_slot?.stored_card
	var/list/formatted = list()
	for(var/job_title in jobs)
		if(!istext(job_title))
			continue
		formatted.Add(list(list(
			"display_name" = replacetext(job_title, " ", "&nbsp"),
			"target_rank" = id_card?.assignment ? id_card.assignment : "Unassigned",
			"job" = job_title)))

	return formatted

/datum/nano_module/program/card_mod/proc/get_accesses(is_centcom = 0)
	return null


/datum/computer_file/program/card_mod/Topic(href, href_list)
	if(..())
		return 1

	var/mob/user = usr
	var/obj/item/card/id/user_id_card = user?.GetIdCard()
	var/obj/item/card/id/id_card = computer?.card_slot?.stored_card
	var/datum/nano_module/program/card_mod/module = NM

	if (!user_id_card || !id_card || !module)
		return

	switch(href_list["action"])
		if("switchm")
			if(href_list["target"] == "mod")
				module.mod_mode = 1
			else if (href_list["target"] == "manifest")
				module.mod_mode = 0
		if("togglea")
			module.show_assignments = !module.show_assignments
		if("print")
			if(!authorized(user_id_card))
				to_chat(usr, SPAN_WARNING("Access denied."))
				return
			if(computer.nano_printer) //This option should never be called if there is no printer
				if(module.mod_mode)
					if(program_has_access(user, 1))
						var/contents = {"<h4>Access Report</h4>
									<u>Prepared By:</u> [user_id_card.registered_name ? user_id_card.registered_name : "Unknown"]<br>
									<u>For:</u> [id_card.registered_name ? id_card.registered_name : "Unregistered"]<br>
									<hr>
									<u>Assignment:</u> [id_card.assignment]<br>
									<u>Account Number:</u> #[id_card.associated_account_number]<br>
									<u>Email account:</u> [id_card.associated_email_login["login"]]
									<u>Email password:</u> [stars(id_card.associated_email_login["password"], 0)]
									<u>Blood Type:</u> [id_card.blood_type]<br><br>
									<u>Access:</u><br>
								"}

						var/known_access_rights = get_access_ids(ACCESS_TYPE_STATION|ACCESS_TYPE_CENTCOM)
						for(var/A in id_card.access)
							if(A in known_access_rights)
								contents += "  [get_access_desc(A)]"

						if(!computer.nano_printer.print_text(contents,"access report"))
							to_chat(usr, SPAN_NOTICE("Hardware error: Printer was unable to print the file. It may be out of paper."))
							return
				else
					var/contents = {"<h4>Crew Manifest</h4>
									<br>
									[html_crew_manifest()]
									"}
					if(!computer.nano_printer.print_text(contents, "crew manifest ([station_time_timestamp("hh:mm")])"))
						to_chat(usr, SPAN_NOTICE("Hardware error: Printer was unable to print the file. It may be out of paper."))
						return
		if("eject")
			if(computer.card_slot?.stored_card)
				computer.card_slot.eject_id(user)
			else
				computer.card_slot?.insert_id(user.get_active_hand(), user)
		if("terminate")
			if(!authorized(user_id_card))
				to_chat(usr, SPAN_WARNING("Access denied."))
				return
			if(computer && program_has_access(user, 1))
				id_card.assignment = "Terminated"
				remove_nt_access(id_card)
				callHook("terminate_employee", list(id_card))
		if("edit")
			if(!authorized(user_id_card))
				to_chat(usr, SPAN_WARNING("Access denied."))
				return

			if(!computer || !program_has_access(user, 1) || !id_card)
				return

			if(href_list["name"])
				var/temp_name = sanitizeName(input("Enter name.", "Name", id_card.registered_name),allow_numbers=TRUE)
				if(temp_name)
					id_card.registered_name = temp_name
					id_card.formal_name_suffix = initial(id_card.formal_name_suffix)
					id_card.formal_name_prefix = initial(id_card.formal_name_prefix)
				else
					to_chat(usr, SPAN_WARNING("Invalid name entered!"))
			else if(href_list["account"])
				var/account_num = text2num(input("Enter account number.", "Account", id_card.associated_account_number))
				if(account_num)
					id_card.associated_account_number = account_num
				else
					to_chat(usr, SPAN_WARNING("Invalid account number entered!"))
			else if(href_list["elogin"])
				var/email_login = input("Enter email login.", "Email login", id_card.associated_email_login["login"])
				id_card.associated_email_login["login"] = email_login
			else if(href_list["epswd"])
				var/email_password = input("Enter email password.", "Email password")
				id_card.associated_email_login["password"] = email_password
		if("assign")
			if(!authorized(user_id_card))
				to_chat(usr, SPAN_WARNING("Access denied."))
				return

			if(!computer || !program_has_access(user, 1) || !id_card)
				return

			var/target_assignment = href_list["assign_target"]
			if(!target_assignment)
				to_chat(usr, SPAN_WARNING("No assignment specified."))
				return

			if(target_assignment == "Custom")
				var/custom_title = sanitize(
					input("Enter a custom job assignment.", "Assignment", id_card.assignment),
					45
				)
				// Custom jobs function as an impromptu alt title, mainly for sechuds
				if(custom_title)
					id_card.assignment = custom_title
			else
				var/list/new_access = list()

				if(module.is_centcom)
					new_access = get_centcom_access(target_assignment)
				else
					var/datum/job/job_datum = SSjobs.get_by_title(target_assignment)
					if(!job_datum)
						to_chat(usr, SPAN_WARNING("No log exists for this job: [target_assignment]"))
						return

					var/list/job_access = job_datum.get_access()
					var/list/valid_access_types = get_access_ids(operating_access_types)
					// Use list intersection to keep only accesses this terminal can modify
					new_access = job_access & valid_access_types

				reset_and_apply_access(id_card, new_access)
				id_card.assignment = target_assignment
				id_card.rank = target_assignment

			callHook("reassign_employee", list(id_card))
		if("access")
			if(!authorized(user_id_card))
				to_chat(usr, SPAN_WARNING("Access denied."))
				return

			// Only proceed if the caller provided an "allowed" flag and we have the
			// necessary hardware / permissions to modify the card.
			if(href_list["allowed"] && computer && program_has_access(user, 1) && id_card)
				var/access_type = text2num(href_list["access_target"])
				var/access_allowed = text2num(href_list["allowed"])

				// Guard: the access type must be one this terminal can modify
				var/list/valid_access_types = get_access_ids(operating_access_types)
				if(access_type in valid_access_types)
					var/region_type = get_access_region_by_id(access_type)

					// Check if the user has any access in the same region, allowing them to modify it
					for(var/user_access in user_id_card.access)
						if(user_access in GLOB.using_map.access_modify_region[region_type])
							// Toggle logic:
							//   access_allowed == 1 (currently has access) → remove it  (toggle OFF)
							//   access_allowed == 0 (currently denied)   → add it    (toggle ON)
							id_card.access -= access_type
							if(!access_allowed)
								id_card.access += access_type
							break

	if(id_card)
		id_card.SetName(text("[id_card.registered_name]'s ID Card ([id_card.assignment])"))

	SSnano.update_uis(NM)
	return 1

/datum/computer_file/program/card_mod/proc/remove_nt_access(obj/item/card/id/id_card)
	id_card.access -= get_access_ids(ACCESS_TYPE_STATION|ACCESS_TYPE_CENTCOM)

/datum/computer_file/program/card_mod/proc/apply_access(obj/item/card/id/id_card, list/accesses)
	id_card.access |= accesses

/// Combined helper: removes station/centcom access from the card, then
/// applies the specified access list. Provides atomicity for assignment changes.
/datum/computer_file/program/card_mod/proc/reset_and_apply_access(obj/item/card/id/id_card, list/new_access)
	remove_nt_access(id_card)
	apply_access(id_card, new_access)

/datum/computer_file/program/card_mod/proc/authorized(obj/item/card/id/id_card)
	return id_card && (ACCESS_CHANGE_IDS in id_card.access)
