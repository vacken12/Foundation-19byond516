/datum/species/scp912
	name = "SCP-912"
	name_plural = "SCP-912s"
	show_ssd = null
	show_coma = null

	species_flags = SPECIES_FLAG_NO_PAIN
	spawn_flags = SPECIES_IS_RESTRICTED

	genders = list(MALE)

	// No default organs — only overridden eyes
	has_organ = list()
	override_organ_types = list(BP_EYES = /obj/item/organ/internal/eyes/scp347)

	// Icon overrides
	icobase = 'icons/SCP/scp347/scp-347.dmi'
	deform = null

	// Damage icon overrides
	damage_overlays = null
	damage_mask = null
	blood_mask = null

	hud_type = /datum/hud_data/scp912

/datum/hud_data/scp912
	has_blink = FALSE
