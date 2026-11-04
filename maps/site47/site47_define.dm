/datum/map/site47
	name = "Зона 47"
	full_name = "Фонд SCP - Зона 47"
	path = "site47"
	flags = MAP_HAS_BRANCH | MAP_HAS_RANK
	station_levels = list(1,2,3)
	contact_levels = list(1,2,3)
	player_levels = list(1,2,3)
	sealed_levels = list(1,2,3)
	base_turf_by_z = list(
		"1" = /turf/simulated/floor/exoplanet/desert,
		"2" = /turf/simulated/floor/exoplanet/desert,
		"3" = /turf/simulated/floor/exoplanet/desert
	)
	overmap_size = 35
	overmap_event_areas = 0
	usable_email_tlds = list("site47.foundation", "security.site47.foundation", "science.site47.foundation", "utility.site47.foundation")

	allowed_spawns = list("Cryogenic Storage", "D-Cells")
	default_spawn = "Cryogenic Storage"

	station_name  = "Фонд SCP - Зона 47"
	station_short = "Зона 47"
	dock_name     = "Аварийная Зона-91"
	boss_name     = "Североамериканское командование Фонда"
	boss_short    = "Региональное командование"
	company_name  = "Фонд SCP"
	company_short = "Фонд"

	//These should probably be moved into the evac controller...
	shuttle_docked_message = "The outbound train is now boarding at the Train Station. It will depart in approximately %ETD%."
	shuttle_leaving_dock = "The outbound train for off-duty personnel is now departing, and will reach its first stop in %ETA%."
	shuttle_called_message = "The work shift is now ending. The next outbound train for off-duty personnel will begin boarding in %ETA%."
	shuttle_recall_message = "The work shift has been extended. Please return to your post."
	emergency_shuttle_docked_message = "The emergency train is now boarding at the Train Station. Evacuation is mandatory for all Foundation personnel. It will depart in %ETD%."
	emergency_shuttle_leaving_dock = "The emergency train is departing for Extraction Site 47-B and will arrive in %ETA%. Please cooperate with Responders upon arrival."
	emergency_shuttle_called_message = "An emergency evacuation has been ordered for this facility. All authorized evacuees must proceed to the outbound Train Station within %ETA%."
	emergency_shuttle_recall_message = "The emergency evacuation has been cancelled. Return to your post."

	evac_controller_type = /datum/evacuation_controller/shuttle //The evacuation controller that the map uses, this MUST be defined else the train will not function.

	default_law_type = /datum/ai_laws/foundation
	use_overmap = 0
	num_exoplanets = 0

	away_site_budget = 3

	can_be_voted = TRUE


/*
/datum/map/torch/setup_map()
	..()
	system_name = generate_system_name()
	minor_announcement = new(new_sound = sound('sounds/AI/torch/commandreport.ogg', volume = 45))
*/
