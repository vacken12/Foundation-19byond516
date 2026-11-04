// Corridor Generation System for Site CB
// Generates random corridors each round starting from /obj/effect/landmark/siteCB/start

// Map templates for corridor presets
/datum/map_template/siteCB/corHori
	name = "Horizontal Corridor"
	width = 9
	height = 5
	tallness = 1
	mappaths = list("maps/siteCB/map_templates/corHori.dmm")

/datum/map_template/siteCB/corHoriR
	name = "Horizontal Corridor with Room"
	width = 7
	height = 5
	tallness = 1
	mappaths = list("maps/siteCB/map_templates/corHoriR.dmm")

/datum/map_template/siteCB/corVert
	name = "Vertical Corridor"
	width = 5
	height = 7
	tallness = 1
	mappaths = list("maps/siteCB/map_templates/corVert.dmm")

/datum/map_template/siteCB/corL
	name = "L-Shaped Corridor"
	width = 7
	height = 7
	tallness = 1
	mappaths = list("maps/siteCB/map_templates/corL.dmm")

/datum/map_template/siteCB/corManifoldHori
	name = "Horizontal Manifold"
	width = 9
	height = 5
	tallness = 1
	mappaths = list("maps/siteCB/map_templates/corManifoldHori.dmm")

/datum/map_template/siteCB/corManifoldVert
	name = "Vertical Manifold"
	width = 5
	height = 7
	tallness = 1
	mappaths = list("maps/siteCB/map_templates/corManifoldVert.dmm")

/datum/map_template/siteCB/corManifold4Fold
	name = "4-Way Manifold"
	width = 9
	height = 9
	tallness = 1
	mappaths = list("maps/siteCB/map_templates/corManifold4Fold.dmm")

// Main corridor generation proc
/datum/map/siteCB/proc/generate_corridors()
	set waitfor = FALSE
	set background = 1

	// Find the start landmark
	var/obj/effect/landmark/siteCB/start_landmark = locate(/obj/effect/landmark/siteCB/start)
	if(!start_landmark)
		log_world("Corridor Generation: Start landmark not found!")
		return

	var/current_x = start_landmark.x
	var/current_y = start_landmark.y
	var/current_z = start_landmark.z

	log_world("Corridor Generation: Starting at [current_x],[current_y],[current_z]")

	// Keep track of placed corridors to avoid overlaps
	var/list/placed_turfs = list()

	// Mark the start area as placed
	mark_placed_turfs(current_x - 2, current_y - 2, current_z, 5, 5, placed_turfs)

	// Generate a random number of corridors (5-12)
	var/corridor_count = rand(5, 12)

	for(var/i = 0; i < corridor_count; i++)
		// Pick a random corridor template type - weighted towards simpler corridors
		var/template_type = pick_corridor_template()

		// Get the mappaths for this template type
		var/list/paths = list("maps/siteCB/map_templates/corHori.dmm")
		if(template_type == /datum/map_template/siteCB/corHoriR)
			paths = list("maps/siteCB/map_templates/corHoriR.dmm")
		else if(template_type == /datum/map_template/siteCB/corVert)
			paths = list("maps/siteCB/map_templates/corVert.dmm")
		else if(template_type == /datum/map_template/siteCB/corL)
			paths = list("maps/siteCB/map_templates/corL.dmm")
		else if(template_type == /datum/map_template/siteCB/corManifoldHori)
			paths = list("maps/siteCB/map_templates/corManifoldHori.dmm")
		else if(template_type == /datum/map_template/siteCB/corManifoldVert)
			paths = list("maps/siteCB/map_templates/corManifoldVert.dmm")
		else if(template_type == /datum/map_template/siteCB/corManifold4Fold)
			paths = list("maps/siteCB/map_templates/corManifold4Fold.dmm")

		var/datum/map_template/siteCB/corridor_template = new template_type(paths)
		if(!corridor_template || !corridor_template.mappaths)
			log_world("Corridor Generation: Failed to create template instance")
			qdel(corridor_template)
			continue

		// Verify template dimensions
		if(corridor_template.width <= 0 || corridor_template.height <= 0)
			if(!corridor_template.preload_size(corridor_template.mappaths))
				// Use defaults
				corridor_template.width = 9
				corridor_template.height = 5

		// Position template centered on current position
		var/place_x = current_x
		var/place_y = current_y

		// Load the corridor template with centered = TRUE so it spreads out from the exit
		var/turf/placement = locate(place_x, place_y, current_z)
		if(!placement || !isturf(placement))
			qdel(corridor_template)
			continue

		var/success = corridor_template.load(placement, centered = TRUE)
		if(success)
			log_world("Corridor Generation: Placed [corridor_template.name] at [place_x],[place_y],[current_z]")

			// Mark placed turfs
			mark_placed_turfs(place_x, place_y, current_z, corridor_template.width, corridor_template.height, placed_turfs)

			// Find an exit to continue from
			var/obj/effect/landmark/siteCB/next_exit = find_exit_in_corridor(place_x, place_y, current_z, corridor_template.width, corridor_template.height)
			if(next_exit)
				// Skip the start landmark - we need to find actual exits
				if(istype(next_exit, /obj/effect/landmark/siteCB/start))
					next_exit = find_alternative_exit(place_x, place_y, current_z, corridor_template.width, corridor_template.height)

				if(next_exit)
					// Move the full template size in the direction the exit points
					if(istype(next_exit, /obj/effect/landmark/siteCB/exit_north))
						current_y = next_exit.y - round(corridor_template.height / 2) - 1
					else if(istype(next_exit, /obj/effect/landmark/siteCB/exit_south))
						current_y = next_exit.y + round(corridor_template.height / 2) + 1
					else if(istype(next_exit, /obj/effect/landmark/siteCB/exit_east))
						current_x = next_exit.x + round(corridor_template.width / 2) + 1
					else if(istype(next_exit, /obj/effect/landmark/siteCB/exit_west))
						current_x = next_exit.x - round(corridor_template.width / 2) - 1
					else
						current_x = next_exit.x
						current_y = next_exit.y
					log_world("Corridor Generation: Next at [current_x],[current_y] (from [next_exit.type])")
				else
					current_x = place_x + round(corridor_template.width / 2)
					current_y = place_y + round(corridor_template.height / 2)
			else
				current_x = place_x + round(corridor_template.width / 2)
				current_y = place_y + round(corridor_template.height / 2)
		else
			log_world("Corridor Generation: Failed to load [corridor_template.name]")

		qdel(corridor_template)

	log_world("Corridor Generation: Completed! Placed [placed_turfs.len] total turfs")

// Helper proc to check for overlaps
/datum/map/siteCB/proc/check_overlap(start_x, start_y, z, width, height, placed_turfs)
	for(var/turf_key in placed_turfs)
		var/list/turf_data = placed_turfs[turf_key]
		var/tx = turf_data[1]
		var/ty = turf_data[2]
		var/tz = turf_data[3]
		var/tw = turf_data[4]
		var/th = turf_data[5]

		// Check if rectangles overlap
		if(z == tz)
			if(!(start_x + width - 1 < tx || start_x > tx + tw - 1 || start_y + height - 1 < ty || start_y > ty + th - 1))
				return TRUE
	return FALSE

// Helper proc to find an exit landmark in a corridor
/datum/map/siteCB/proc/find_exit_in_corridor(start_x, start_y, z, width, height)
	// Search edges for exit landmarks - only on the exact edge turfs, not nearby
	// Top edge
	for(var/x = start_x to start_x + width - 1)
		var/turf/T = locate(x, start_y, z)
		if(T)
			for(var/obj/effect/landmark/siteCB/exit_north in T)
				if(exit_north.z == z)
					return exit_north
			for(var/obj/effect/landmark/siteCB/exit_south in T)
				if(exit_south.z == z)
					return exit_south

	// Bottom edge
	for(var/x = start_x to start_x + width - 1)
		var/turf/T = locate(x, start_y + height - 1, z)
		if(T)
			for(var/obj/effect/landmark/siteCB/exit_north in T)
				if(exit_north.z == z)
					return exit_north
			for(var/obj/effect/landmark/siteCB/exit_south in T)
				if(exit_south.z == z)
					return exit_south

	// Left edge
	for(var/y = start_y to start_y + height - 1)
		var/turf/T = locate(start_x, y, z)
		if(T)
			for(var/obj/effect/landmark/siteCB/exit_east in T)
				if(exit_east.z == z)
					return exit_east
			for(var/obj/effect/landmark/siteCB/exit_west in T)
				if(exit_west.z == z)
					return exit_west

	// Right edge
	for(var/y = start_y to start_y + height - 1)
		var/turf/T = locate(start_x + width - 1, y, z)
		if(T)
			for(var/obj/effect/landmark/siteCB/exit_east in T)
				if(exit_east.z == z)
					return exit_east
			for(var/obj/effect/landmark/siteCB/exit_west in T)
				if(exit_west.z == z)
					return exit_west

	// Also check for room landmarks in the center
	var/turf/center = locate(start_x + round(width/2), start_y + round(height/2), z)
	if(center)
		for(var/obj/effect/landmark/siteCB/room in center)
			if(room.z == z)
				return room

	return null

// Helper proc to get offset based on exit direction in a corridor
/datum/map/siteCB/proc/get_exit_offset(start_x, start_y, z, width, height)
	// Check each edge for exits and return appropriate offset
	// Top edge - exit_north means next corridor goes north (up, negative Y)
	for(var/x = start_x to start_x + width - 1)
		var/turf/T = locate(x, start_y, z)
		if(T)
			for(var/obj/effect/landmark/siteCB/exit_north in range(1, T))
				if(exit_north.z == z)
					return list(0, -1)  // Move up

	// Bottom edge - exit_south means next corridor goes south (down, positive Y)
	for(var/x = start_x to start_x + width - 1)
		var/turf/T = locate(x, start_y + height - 1, z)
		if(T)
			for(var/obj/effect/landmark/siteCB/exit_south in range(1, T))
				if(exit_south.z == z)
					return list(0, 1)  // Move down

	// Left edge - exit_west means next corridor goes west (left, negative X)
	for(var/y = start_y to start_y + height - 1)
		var/turf/T = locate(start_x, y, z)
		if(T)
			for(var/obj/effect/landmark/siteCB/exit_west in range(1, T))
				if(exit_west.z == z)
					return list(-1, 0)  // Move left

	// Right edge - exit_east means next corridor goes east (right, positive X)
	for(var/y = start_y to start_y + height - 1)
		var/turf/T = locate(start_x + width - 1, y, z)
		if(T)
			for(var/obj/effect/landmark/siteCB/exit_east in range(1, T))
				if(exit_east.z == z)
					return list(1, 0)  // Move right

	return null

// Helper proc to find any available exit in a corridor
/datum/map/siteCB/proc/find_any_exit(start_x, start_y, z, width, height)
	// Search for exits on the edges of the corridor
	var/list/edge_positions = list()

	// Top edge (exit_north connections)
	for(var/x = start_x to start_x + width - 1)
		edge_positions += list(x, start_y)

	// Bottom edge (exit_south connections)
	for(var/x = start_x to start_x + width - 1)
		edge_positions += list(x, start_y + height - 1)

	// Left edge (exit_west connections)
	for(var/y = start_y to start_y + height - 1)
		edge_positions += list(start_x, y)

	// Right edge (exit_east connections)
	for(var/y = start_y to start_y + height - 1)
		edge_positions += list(start_x + width - 1, y)

	// Pick a random edge position and return it
	var/pos = pick(edge_positions)
	return locate(pos[1], pos[2], z)

// Helper proc to pick a random corridor template (weighted)
/datum/map/siteCB/proc/pick_corridor_template()
	var/list/template_types = list(
		/datum/map_template/siteCB/corHori,
		/datum/map_template/siteCB/corHori,
		/datum/map_template/siteCB/corHori,
		/datum/map_template/siteCB/corVert,
		/datum/map_template/siteCB/corVert,
		/datum/map_template/siteCB/corL,
		/datum/map_template/siteCB/corManifoldHori,
		/datum/map_template/siteCB/corManifoldVert,
		/datum/map_template/siteCB/corManifold4Fold
	)
	return pick(template_types)

// Helper proc to get the type of exit at a position
/datum/map/siteCB/proc/get_current_exit_type(x, y, z)
	var/turf/T = locate(x, y, z)
	if(!T)
		return null

	// Check if there's an exit landmark at this position
	for(var/obj/effect/landmark/siteCB/exit_north in range(0, T))
		if(exit_north.z == z)
			return /obj/effect/landmark/siteCB/exit_north
	for(var/obj/effect/landmark/siteCB/exit_south in range(0, T))
		if(exit_south.z == z)
			return /obj/effect/landmark/siteCB/exit_south
	for(var/obj/effect/landmark/siteCB/exit_east in range(0, T))
		if(exit_east.z == z)
			return /obj/effect/landmark/siteCB/exit_east
	for(var/obj/effect/landmark/siteCB/exit_west in range(0, T))
		if(exit_west.z == z)
			return /obj/effect/landmark/siteCB/exit_west
	for(var/obj/effect/landmark/siteCB/room in range(0, T))
		if(room.z == z)
			return /obj/effect/landmark/siteCB/room

	return null

// Helper proc to get matching template for an exit type
/datum/map/siteCB/proc/get_matching_template(exit_type)
	// Return a template that has a matching exit
	// This is simplified - in reality you'd check the template's landmark positions
	if(exit_type == /obj/effect/landmark/siteCB/exit_north || exit_type == /obj/effect/landmark/siteCB/exit_south)
		return /datum/map_template/siteCB/corVert
	else if(exit_type == /obj/effect/landmark/siteCB/exit_east || exit_type == /obj/effect/landmark/siteCB/exit_west)
		return /datum/map_template/siteCB/corHori
	else
		return /datum/map_template/siteCB/corHori

// Helper proc to find an alternative exit (not start)
/datum/map/siteCB/proc/find_alternative_exit(start_x, start_y, z, width, height)
	// Search edges for exit landmarks, excluding start
	// Top edge
	for(var/x = start_x to start_x + width - 1)
		var/turf/T = locate(x, start_y, z)
		if(T)
			for(var/obj/effect/landmark/siteCB/exit_north in T)
				if(exit_north.z == z && !istype(exit_north, /obj/effect/landmark/siteCB/start))
					return exit_north
			for(var/obj/effect/landmark/siteCB/exit_south in T)
				if(exit_south.z == z && !istype(exit_south, /obj/effect/landmark/siteCB/start))
					return exit_south

	// Bottom edge
	for(var/x = start_x to start_x + width - 1)
		var/turf/T = locate(x, start_y + height - 1, z)
		if(T)
			for(var/obj/effect/landmark/siteCB/exit_north in T)
				if(exit_north.z == z && !istype(exit_north, /obj/effect/landmark/siteCB/start))
					return exit_north
			for(var/obj/effect/landmark/siteCB/exit_south in T)
				if(exit_south.z == z && !istype(exit_south, /obj/effect/landmark/siteCB/start))
					return exit_south

	// Left edge
	for(var/y = start_y to start_y + height - 1)
		var/turf/T = locate(start_x, y, z)
		if(T)
			for(var/obj/effect/landmark/siteCB/exit_east in T)
				if(exit_east.z == z && !istype(exit_east, /obj/effect/landmark/siteCB/start))
					return exit_east
			for(var/obj/effect/landmark/siteCB/exit_west in T)
				if(exit_west.z == z && !istype(exit_west, /obj/effect/landmark/siteCB/start))
					return exit_west

	// Right edge
	for(var/y = start_y to start_y + height - 1)
		var/turf/T = locate(start_x + width - 1, y, z)
		if(T)
			for(var/obj/effect/landmark/siteCB/exit_east in T)
				if(exit_east.z == z && !istype(exit_east, /obj/effect/landmark/siteCB/start))
					return exit_east
			for(var/obj/effect/landmark/siteCB/exit_west in T)
				if(exit_west.z == z && !istype(exit_west, /obj/effect/landmark/siteCB/start))
					return exit_west

	// Also check for room landmarks in the center
	var/turf/center = locate(start_x + round(width/2), start_y + round(height/2), z)
	if(center)
		for(var/obj/effect/landmark/siteCB/room in center)
			if(room.z == z && !istype(room, /obj/effect/landmark/siteCB/start))
				return room

	return null

// Helper proc to mark turfs as placed
/datum/map/siteCB/proc/mark_placed_turfs(start_x, start_y, z, width, height, placed_turfs)
	for(var/x = start_x to start_x + width - 1)
		for(var/y = start_y to start_y + height - 1)
			var/turf/T = locate(x, y, z)
			if(T)
				placed_turfs["[x],[y],[z]"] = list(x, y, z, width, height)
