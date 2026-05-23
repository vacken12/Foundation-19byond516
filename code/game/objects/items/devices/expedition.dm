//
// Expedition Camera System
//

/obj/item/device/expedition_camera
	name = "expedition camera"
	desc = "A ruggedized expedition camera for remote field missions."
	icon = 'icons/obj/device.dmi'
	icon_state = "expedition_camera"
	item_state = "expedition_camera"

	obj_flags = OBJ_FLAG_CONDUCTIBLE
	force = 5.0
	w_class = ITEM_SIZE_LARGE
	slot_flags = SLOT_BELT
	throwforce = 5.0
	throw_range = 15
	throw_speed = 3

	origin_tech = list(TECH_DATA = 1, TECH_ENGINEERING = 1, TECH_ESOTERIC = 3)

	var/obj/machinery/camera/spy/camera
	var/drone_id = null

/obj/item/device/expedition_camera/New()
	..()
	drone_id = "EXPD-[sequential_id("expedition_drone")]"
	camera = new(src)
	camera.c_tag = "[drone_id]"
	camera.name = "[drone_id]"

/obj/item/device/expedition_camera/Destroy()
	QDEL_NULL(camera)
	return ..()

/obj/item/device/expedition_camera/examine(mob/user, distance)
	. = ..()
	if(distance <= 0)
		to_chat(user, "It's an expedition camera with integrated speaker.")
		to_chat(user, "Bring it in contact with an expedition monitor to pair them.")

/obj/item/device/expedition_camera/attackby(obj/W as obj, mob/living/user as mob)
	if(istype(W, /obj/item/device/expedition_monitor))
		var/obj/item/device/expedition_monitor/EM = W
		EM.pair(src, user)
	else
		..()

/obj/item/device/expedition_camera/proc/announce_message(message, mob/sender)
	visible_message(SPAN_NOTICE("\The [src] crackles: \"[message]\""))
	playsound(src, "sounds/effects/compbeep[rand(1,5)].ogg", 30, 1)


/obj/item/device/expedition_monitor
	name = "expedition monitor"
	desc = "A portable monitoring device for expedition cameras."
	icon = 'icons/obj/device.dmi'
	icon_state = "expedition_monitor"
	item_state = "expedition_monitor"

	w_class = ITEM_SIZE_SMALL

	origin_tech = list(TECH_DATA = 1, TECH_ENGINEERING = 1, TECH_ESOTERIC = 3)

	var/operating = 0
	var/obj/machinery/camera/spy/selected_camera
	var/list/obj/machinery/camera/spy/cameras = new()

/obj/item/device/expedition_monitor/examine(mob/user, distance)
	. = ..()
	if(distance <= 1)
		to_chat(user, "The screen displays 'EXPEDITION NETWORK' and a list of paired cameras.")

/obj/item/device/expedition_monitor/attack_self(mob/user)
	if(operating)
		return

	add_fingerprint(user)
	user.set_machine(src)

	var/dat = list()
	dat += "<h3>Expedition Monitor</h3><hr>"
	dat += "Paired cameras: [cameras.len]<br>"
	dat += "<hr>"
	dat += "<a href='byond://?src=\ref[src];message=1'>Send Message</a><br>"
	dat += "<a href='byond://?src=\ref[src];view=1'>View Cameras</a><br>"

	var/datum/browser/popup = new(user, "exp_monitor", "Expedition Monitor", 300, 250, src)
	popup.set_content(jointext(dat, null))
	popup.open()

/obj/item/device/expedition_monitor/Topic(href, href_list, state = GLOB.physical_state)
	if(..())
		return 1

	if(href_list["message"])
		if(!cameras.len)
			to_chat(usr, SPAN_WARNING("No paired cameras!"))
			return

		var/list/camera_choices = list()
		for(var/obj/machinery/camera/spy/C in cameras)
			camera_choices += C

		var/obj/machinery/camera/spy/target_camera = input("Select camera to send message to.") as null|anything in camera_choices
		if(!target_camera)
			return

		var/message = sanitize(input("Enter message to transmit.") as text|null)
		if(!message)
			return

		var/obj/item/device/expedition_camera/EC = target_camera.loc
		if(istype(EC))
			EC.announce_message(message, usr)
			to_chat(usr, SPAN_NOTICE("Message sent to [target_camera]."))
		else
			to_chat(usr, SPAN_WARNING("Camera not found!"))

	if(href_list["view"])
		view_cameras(usr)

	if(!href_list["close"])
		attack_self(usr)

/obj/item/device/expedition_monitor/attackby(obj/W as obj, mob/living/user as mob)
	if(istype(W, /obj/item/device/expedition_camera))
		pair(W, user)
	else
		return ..()

/obj/item/device/expedition_monitor/proc/pair(obj/item/device/expedition_camera/EC, mob/living/user)
	if(EC.camera in cameras)
		to_chat(user, SPAN_NOTICE("\The [EC] has been unpaired from \the [src]."))
		cameras -= EC.camera
	else
		to_chat(user, SPAN_NOTICE("\The [EC] has been paired with \the [src]."))
		cameras += EC.camera

/obj/item/device/expedition_monitor/proc/view_cameras(mob/user)
	if(!can_use_cam(user))
		return

	selected_camera = cameras[1]
	view_camera(user)

	operating = 1
	while(selected_camera && Adjacent(user))
		selected_camera = input("Select expedition camera to view.") as null|anything in cameras
	view_camera(user)
	selected_camera = null
	operating = 0

/obj/item/device/expedition_monitor/proc/view_camera(mob/user)
	spawn(0)
		while(selected_camera && Adjacent(user))
			var/turf/T = get_turf(selected_camera)
			if(!T || !selected_camera.can_use())
				user.unset_machine()
				user.reset_view(null)
				to_chat(user, SPAN_NOTICE("[selected_camera] unavailable."))
				sleep(90)
			else
				user.set_machine(selected_camera)
				user.reset_view(selected_camera)
			sleep(10)
		user.unset_machine()
		user.reset_view(null)

/obj/item/device/expedition_monitor/proc/can_use_cam(mob/user)
	if(operating)
		return FALSE

	if(!cameras.len)
		to_chat(user, SPAN_WARNING("No paired cameras detected!"))
		to_chat(user, SPAN_WARNING("Bring an expedition camera in contact with this device to pair the camera."))
		return FALSE

	return TRUE
