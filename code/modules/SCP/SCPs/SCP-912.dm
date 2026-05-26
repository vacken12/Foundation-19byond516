/mob/living/carbon/human/scp912
	name = "mysterious SWAT armor"
	desc = "A set of sentient SWAT armor, usually known to be local Special Weapons and Tactics standard-issue equipment, if a little outdated. They don't seem to respond when talked to, and only acknowledge those who are dressed as local police officers."

	status_flags = NO_ANTAG | GODMODE

/mob/living/carbon/human/scp912/Initialize(mapload, new_species = "SCP-912")
	. = ..()
	SCP = new /datum/scp(
		src, // Ref to actual SCP atom
		"mysterious SWAT armor", //Name (Should not be the scp desg, more like what it can be described as to viewers)
		SCP_SAFE, //Obj Class
		"912", //Numerical Designation
		SCP_PLAYABLE|SCP_ROLEPLAY
	)
	add_verb(src, /client/proc/scpooc)

	SCP.min_time = 10 MINUTES

	init_skills()

	var/decl/hierarchy/outfit/scp912/outfit = outfit_by_type(/decl/hierarchy/outfit/scp912)
	outfit.equip(src)


/mob/living/carbon/human/scp912/Life()
	. = ..()

	// Check if SCP-912 is naked (missing his clothes)
	if(stat == DEAD)
		return

	var/has_required_equipment = FALSE

	// Verify all essential equipment slots are occupied (BYOND DM REQUIRES SINGLE LINE IF CONDITIONS)
	if(src.wear_suit && src.head && src.shoes && src.wear_mask)
		has_required_equipment = TRUE

	if(!has_required_equipment)
		// SCP-912 dies when stripped naked
		visible_message("<span class='warning'>\The [src] powers down and falls inert!</span>")
		src.death(0, "powers down and falls inert.")

/mob/living/carbon/human/scp912/proc/init_skills()
	skillset.skill_list = list()
	for(var/decl/hierarchy/skill/skill_decl in GLOB.skills)
		skillset.skill_list[skill_decl.type] = SKILL_UNTRAINED
	skillset.skill_list[SKILL_COMBAT] = SKILL_MASTER
	skillset.skill_list[SKILL_WEAPONS] = SKILL_MASTER
	skillset.skill_list[SKILL_FORENSICS] = SKILL_TRAINED
	skillset.skill_list[SKILL_HAULING] = SKILL_TRAINED
	skillset.on_levels_change()

/mob/living/carbon/human/scp912/Login()
	. = ..()
	if(client)
		add_language(LANGUAGE_ENGLISH, FALSE) // cant speak
