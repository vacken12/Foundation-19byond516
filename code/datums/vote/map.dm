/datum/vote/map
	name = "Change Map"

/datum/vote/map/can_be_initiated(mob/by_who, forced)
	if(!forced && !is_admin(by_who))
		return FALSE // Must be an admin.
	return ..()

/datum/vote/map/New()
	. = ..()
	default_choices = list()

	for(var/map_path in GLOB.all_maps)
	{
		var/datum/map/M = GLOB.all_maps[map_path]
		if(M.can_be_voted == TRUE)
			default_choices += M.name
	}

/datum/vote/map/finalize_vote(winning_option)
	var/datum/map/M

	for(var/map_path in GLOB.all_maps)
	{
		var/datum/map/candidate = GLOB.all_maps[map_path]
		if(candidate && candidate.name == winning_option)
		{
			M = candidate
			break
		}
	}

	if(M)
	{
		to_world("<span class='notice'>Map has been changed to: <b>[M.name]</b></span>")
		fdel("data/use_map") // del last cache file
		text2file("[M.type]", "data/use_map") // and make new
		return
	}

//Used by the ticker.
/datum/vote/map/end_game
	name = "Round End Map Vote"

/datum/vote/map/end_game/is_accessible_vote()
	return FALSE

/datum/vote/map/end_game/can_be_initiated(mob/by_who, forced)
	if(!isnull(by_who))
		return FALSE
	return ..()

/datum/vote/map/end_game/finalize_vote()
	SSticker.end_game_state = END_GAME_READY_TO_END
	. = ..()

/datum/vote/map/end_game/create_vote(mob/vote_creator, forced)
	SSticker.end_game_state = END_GAME_AWAITING_MAP
	. = ..()


