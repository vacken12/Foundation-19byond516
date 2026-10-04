#define SCPNET_SEARCH_MAX_QUERY 80
#define SCPNET_MAX_TABS 6

/datum/scpnet_tab
	var/id
	var/site_id
	var/slug
	var/view = "home"
	var/query
	var/list/results = list()
	var/error
	var/pending = FALSE
	var/request = 0
	var/generation = 0
	var/list/back = list()
	var/list/forward = list()

/datum/scpnet_tab/proc/snapshot()
	return list("site_id" = site_id, "slug" = slug, "view" = view, "query" = query, "results" = results.Copy())

/datum/scpnet_tab/proc/restore(list/entry)
	site_id = entry["site_id"]
	slug = entry["slug"]
	view = entry["view"]
	query = entry["query"]
	results = entry["results"]
	error = null

/datum/computer_file/program/scpnet
	filename = "scpnet"
	filedesc = "SCPnet"
	program_icon_state = "generic"
	program_menu_icon = "globe"
	extended_desc = "Браузер общедоступных страниц SCPnet. Требует подключения к SCiPnet."
	size = 6
	requires_ntnet = TRUE
	available_on_ntnet = TRUE
	usage_flags = PROGRAM_ALL
	network_destination = "SCPnet"
	tgui_id = "NtosSCPnet"

	var/list/tabs = list()
	var/active_tab
	var/next_tab_id = 0

/datum/computer_file/program/scpnet/Destroy()
	QDEL_LIST(tabs)
	return ..()

/datum/computer_file/program/scpnet/proc/open_tab()
	if(length(tabs) >= SCPNET_MAX_TABS)
		return
	var/datum/scpnet_tab/tab = new
	tab.id = ++next_tab_id
	tabs += tab
	active_tab = tab.id
	return tab

/datum/computer_file/program/scpnet/proc/current_tab()
	for(var/datum/scpnet_tab/tab as anything in tabs)
		if(tab.id == active_tab)
			return tab
	if(!length(tabs))
		return open_tab()
	var/datum/scpnet_tab/last = tabs[length(tabs)]
	active_tab = last.id
	return last

/datum/computer_file/program/scpnet/proc/tab_title(datum/scpnet_tab/tab)
	if(tab.site_id)
		var/list/cached = SSscpnet.pages[json_encode(list(tab.site_id, tab.slug))]
		if(cached)
			return cached["title"]
		var/list/site = SSscpnet.sites[tab.site_id]
		return site ? site["title"] : "Загрузка…"
	if(tab.query)
		return "Поиск"
	switch(tab.view)
		if("catalog")
			return "Список сайтов"
		if("create")
			return "Создать сайт"
	return "Новая вкладка"

/datum/computer_file/program/scpnet/proc/address_of(datum/scpnet_tab/tab)
	if(!tab.site_id)
		return tab.query ? "scpnet://search" : "scpnet://[tab.view]"
	var/list/site = SSscpnet.sites[tab.site_id]
	if(!site)
		return ""
	return tab.slug == "index" ? site["domain"] : "[site["domain"]]/[tab.slug]"

/datum/computer_file/program/scpnet/tgui_data(mob/user, datum/tgui/ui, datum/tgui_state/state)
	var/list/data = get_header_data()
	SSscpnet.last_used = world.time
	SSscpnet.refresh_index()
	var/datum/scpnet_tab/tab = current_tab()
	if(length(tab.results) && tab.generation != SSscpnet.generation)
		tab.generation = SSscpnet.generation
		for(var/list/entry as anything in tab.results.Copy())
			if(!SSscpnet.has_page(entry["site_id"], entry["slug"]))
				tab.results -= list(entry)
	if(tab.site_id && !SSscpnet.has_page(tab.site_id, tab.slug))
		tab.site_id = null
		tab.slug = null
	var/cache_key = json_encode(list(tab.site_id, tab.slug))
	if(tab.site_id)
		SSscpnet.request_page(tab.site_id, tab.slug)
	var/list/strip = list()
	for(var/datum/scpnet_tab/entry as anything in tabs)
		strip += list(list("id" = entry.id, "title" = tab_title(entry), "active" = entry.id == active_tab))
	var/client/viewer = user.client
	data["tabs"] = strip
	data["can_open_tab"] = length(tabs) < SCPNET_MAX_TABS
	data["available"] = SSscpnet.available
	data["loading"] = tab.site_id ? !SSscpnet.pages[cache_key] && !SSscpnet.page_failed(tab.site_id, tab.slug) : SSscpnet.index_pending
	data["failed"] = tab.site_id && SSscpnet.page_failed(tab.site_id, tab.slug)
	data["catalog"] = SSscpnet.catalog
	data["site"] = SSscpnet.sites[tab.site_id]
	data["page"] = SSscpnet.pages[cache_key]
	data["view"] = tab.view
	data["address"] = address_of(tab)
	data["has_back"] = !!length(tab.back)
	data["has_forward"] = !!length(tab.forward)
	data["theme"] = viewer?.scpnet_light_theme ? "light" : "dark"
	var/list/viewer_entry = tab.site_id && viewer ? viewer.scpnet_viewer_tokens[tab.site_id] : null
	data["viewer"] = list(
		"token" = tab.site_id ? SSscpnet.viewer_token(viewer, tab.site_id) : null,
		"error" = LAZYACCESS(viewer_entry, "error"),
	)
	data["search"] = list(
		"query" = tab.query,
		"results" = tab.results,
		"pending" = tab.pending,
		"error" = tab.error,
	)
	data["login"] = list(
		"code" = viewer && viewer.scpnet_code_expires > world.time ? viewer.scpnet_code : null,
		"pending" = viewer?.scpnet_login_pending,
		"retry_seconds" = viewer ? max(0, Ceiling((viewer.scpnet_login_retry - world.time) / (1 SECONDS))) : 0,
		"error" = viewer?.scpnet_login_error,
	)
	return data

/datum/computer_file/program/scpnet/tgui_act(action, list/params, datum/tgui/ui, datum/tgui_state/state)
	if(..())
		return TRUE
	var/datum/scpnet_tab/tab = current_tab()
	switch(action)
		if("login")
			SSscpnet.request_login(ui.user.client)
			return TRUE
		if("theme")
			var/client/viewer = ui.user.client
			if(viewer)
				viewer.scpnet_light_theme = !viewer.scpnet_light_theme
			return TRUE
		if("open")
			open_page(params["site_id"], params["slug"])
			return TRUE
		if("go")
			var/list/target = SSscpnet.resolve(params["query"])
			if(target)
				open_page(target[1], target[2])
				return TRUE
			search(params["query"])
			return TRUE
		if("home")
			go_to("home")
			return TRUE
		if("view")
			if(!(params["name"] in list("home", "catalog", "create")))
				return TRUE
			go_to(params["name"])
			return TRUE
		if("back")
			step_history(tab.back, tab.forward)
			return TRUE
		if("forward")
			step_history(tab.forward, tab.back)
			return TRUE
		if("refresh")
			SSscpnet.force_refresh(tab.site_id, tab.slug)
			return TRUE
		if("token")
			SSscpnet.request_viewer_token(ui.user.client, tab.site_id, ui.user.real_name, !!params["renew"])
			return TRUE
		if("tab_open")
			open_tab()
			return TRUE
		if("tab_select")
			var/wanted = text2num("[params["id"]]")
			for(var/datum/scpnet_tab/entry as anything in tabs)
				if(entry.id == wanted)
					active_tab = entry.id
			return TRUE
		if("tab_close")
			close_tab(text2num("[params["id"]]"))
			return TRUE

/datum/computer_file/program/scpnet/proc/close_tab(tab_id)
	for(var/datum/scpnet_tab/entry as anything in tabs)
		if(entry.id != tab_id)
			continue
		tabs -= entry
		qdel(entry)
		if(active_tab == tab_id && length(tabs))
			var/datum/scpnet_tab/last = tabs[length(tabs)]
			active_tab = last.id
		return

/datum/computer_file/program/scpnet/proc/step_history(list/source, list/destination)
	if(!length(source))
		return
	var/datum/scpnet_tab/tab = current_tab()
	destination += list(tab.snapshot())
	var/list/entry = source[length(source)]
	source.Cut(length(source))
	tab.restore(entry)
	if(tab.site_id)
		SSscpnet.request_page(tab.site_id, tab.slug)

/datum/computer_file/program/scpnet/proc/remember()
	var/datum/scpnet_tab/tab = current_tab()
	tab.back += list(tab.snapshot())
	tab.forward.Cut()
	return tab

/datum/computer_file/program/scpnet/proc/go_to(name)
	var/datum/scpnet_tab/tab = remember()
	tab.view = name
	tab.site_id = null
	tab.slug = null
	tab.query = null
	tab.results = list()
	tab.error = null

/datum/computer_file/program/scpnet/proc/open_page(target_id, target_slug)
	if(!SSscpnet.has_page(target_id, target_slug))
		return
	var/datum/scpnet_tab/tab = remember()
	tab.site_id = target_id
	tab.slug = target_slug
	tab.error = null
	SSscpnet.request_page(target_id, target_slug)

/datum/computer_file/program/scpnet/proc/search(raw_query)
	var/datum/scpnet_tab/tab = current_tab()
	if(!istext(raw_query) || tab.pending)
		return
	var/query = trim(raw_query)
	if(length_char(query) < 2 || length_char(query) > SCPNET_SEARCH_MAX_QUERY)
		tab.error = "Введите от 2 до [SCPNET_SEARCH_MAX_QUERY] символов."
		return
	tab.request++
	if(!SSscpnet.search(query, CALLBACK(src, PROC_REF(on_search), tab.id, tab.request)))
		tab.error = "SCPnet занят. Попробуйте ещё раз."
		return
	remember()
	tab.site_id = null
	tab.slug = null
	tab.query = query
	tab.results = list()
	tab.error = null
	tab.pending = TRUE

/datum/computer_file/program/scpnet/proc/on_search(tab_id, request_id, list/response)
	if(QDELETED(src))
		return
	for(var/datum/scpnet_tab/tab as anything in tabs)
		if(tab.id != tab_id || !tab.pending || tab.request != request_id)
			continue
		tab.pending = FALSE
		var/list/found = SSscpnet.search_results(response)
		if(isnull(found))
			tab.error = "Не удалось выполнить поиск."
		else
			tab.results = found
			tab.generation = SSscpnet.generation
			tab.error = null
		break
	if(computer)
		SStgui.update_uis(computer)

#undef SCPNET_SEARCH_MAX_QUERY
#undef SCPNET_MAX_TABS
