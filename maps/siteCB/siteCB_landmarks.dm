/obj/effect/landmark/siteCB
	invisibility = 1

/obj/effect/landmark/siteCB/start //start proceduring
	icon_state = "x3"

/obj/effect/landmark/siteCB/exit1 // first exit in corridors (dont works -> updated to exit_south etc)
	icon_state = "exit_1"

/obj/effect/landmark/siteCB/exit2 // second exit in corridors
	icon_state = "exit_2"

/obj/effect/landmark/siteCB/exit3 // third exit in corridors
	icon_state = "exit_3"

/obj/effect/landmark/siteCB/exit_north // second exit in corridors
	icon_state = "exit_north"

/obj/effect/landmark/siteCB/exit_east // third exit in corridors
	icon_state = "exit_east"

/obj/effect/landmark/siteCB/exit_south // second exit in corridors
	icon_state = "exit_south"

/obj/effect/landmark/siteCB/exit_west // third exit in corridors
	icon_state = "exit_west"



/obj/effect/landmark/siteCB/room // room exit in corridors (open to room with something)
	icon_state = "room"

/obj/effect/landmark/siteCB/corHori // horizontal corridor 7x5
	var/datum/map_template/siteCB/corHori

/obj/effect/landmark/corVert // vertical corridor 5x7
	var/datum/map_template/siteCB/corVeri
