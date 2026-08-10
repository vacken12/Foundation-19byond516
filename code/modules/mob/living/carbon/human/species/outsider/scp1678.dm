/datum/species/scp1678
	name = "SCP-1678-E"
	blood_color = "#a10808"
	flesh_color = "#2a2a2a"
	spawn_flags = SPECIES_IS_RESTRICTED
	has_fine_manipulation = TRUE
	genders = list(MALE, FEMALE)
	total_health = 100

	has_limbs = list(
		BP_CHEST =  list("path" = /obj/item/organ/external/chest/scp1678),
		BP_GROIN =  list("path" = /obj/item/organ/external/groin/scp1678),
		BP_HEAD =   list("path" = /obj/item/organ/external/head/scp1678),
		BP_L_ARM =  list("path" = /obj/item/organ/external/arm/scp1678),
		BP_R_ARM =  list("path" = /obj/item/organ/external/arm/right/scp1678),
		BP_L_LEG =  list("path" = /obj/item/organ/external/leg/scp1678),
		BP_R_LEG =  list("path" = /obj/item/organ/external/leg/right/scp1678),
		BP_L_HAND = list("path" = /obj/item/organ/external/hand/scp1678),
		BP_R_HAND = list("path" = /obj/item/organ/external/hand/right/scp1678),
		BP_L_FOOT = list("path" = /obj/item/organ/external/foot/scp1678),
		BP_R_FOOT = list("path" = /obj/item/organ/external/foot/right/scp1678)
	)

	has_organ = list(
		BP_HEART =    /obj/item/organ/internal/heart,
		BP_STOMACH =  /obj/item/organ/internal/stomach,
		BP_LUNGS =    /obj/item/organ/internal/lungs,
		BP_LIVER =    /obj/item/organ/internal/liver,
		BP_KIDNEYS =  /obj/item/organ/internal/kidneys,
		BP_BRAIN =    /obj/item/organ/internal/brain,
		BP_APPENDIX = /obj/item/organ/internal/appendix,
		BP_EYES =     /obj/item/organ/internal/eyes
	)

	icobase = null
	deform = null
	damage_overlays = null
	damage_mask = null
	blood_mask = null

	brute_mod = 1.0
	burn_mod = 1.0
	oxy_mod = 0.0
	toxins_mod = 0.0
	radiation_mod = 0.0
	flash_mod = 0.0

/datum/species/scp1678/A
	name = "SCP-1678-A"
	species_flags = SPECIES_FLAG_NO_SLIP | SPECIES_FLAG_NO_POISON | SPECIES_FLAG_NO_PAIN
	siemens_coefficient = 0
	total_health = 200
	hud_type = /datum/hud_data/scp1678
	genders = list(MALE)
	blood_color = "#1a1a1a"
	flesh_color = "#2a2a2a"

	has_limbs = list(
		BP_CHEST =  list("path" = /obj/item/organ/external/chest/scp1678),
		BP_GROIN =  list("path" = /obj/item/organ/external/groin/scp1678),
		BP_HEAD =   list("path" = /obj/item/organ/external/head/scp1678),
		BP_L_ARM =  list("path" = /obj/item/organ/external/arm/scp1678),
		BP_R_ARM =  list("path" = /obj/item/organ/external/arm/right/scp1678),
		BP_L_LEG =  list("path" = /obj/item/organ/external/leg/scp1678),
		BP_R_LEG =  list("path" = /obj/item/organ/external/leg/right/scp1678),
		BP_L_HAND = list("path" = /obj/item/organ/external/hand/scp1678),
		BP_R_HAND = list("path" = /obj/item/organ/external/hand/right/scp1678),
		BP_L_FOOT = list("path" = /obj/item/organ/external/foot/scp1678),
		BP_R_FOOT = list("path" = /obj/item/organ/external/foot/right/scp1678)
	)

	has_organ = list(
		BP_HEART =    /obj/item/organ/internal/heart,
		BP_STOMACH =  /obj/item/organ/internal/stomach,
		BP_LUNGS =    /obj/item/organ/internal/lungs,
		BP_LIVER =    /obj/item/organ/internal/liver,
		BP_KIDNEYS =  /obj/item/organ/internal/kidneys,
		BP_BRAIN =    /obj/item/organ/internal/brain,
		BP_APPENDIX = /obj/item/organ/internal/appendix,
		BP_EYES =     /obj/item/organ/internal/eyes
	)

	icobase = null
	deform = null
	damage_overlays = null
	damage_mask = null
	blood_mask = null

	brute_mod = 1.0
	burn_mod = 1.0
	oxy_mod = 0.0
	toxins_mod = 0.0
	radiation_mod = 0.0
	flash_mod = 0.0

/obj/item/organ/external/chest/scp1678
	max_damage = 100
	min_broken_damage = 65
	arterial_bleed_severity = 0

/obj/item/organ/external/groin/scp1678
	max_damage = 90
	min_broken_damage = 55
	arterial_bleed_severity = 0

/obj/item/organ/external/head/scp1678
	max_damage = 80
	min_broken_damage = 50
	arterial_bleed_severity = 0

/obj/item/organ/external/arm/scp1678
	max_damage = 65
	min_broken_damage = 45
	arterial_bleed_severity = 0

/obj/item/organ/external/arm/right/scp1678
	max_damage = 65
	min_broken_damage = 45
	arterial_bleed_severity = 0

/obj/item/organ/external/leg/scp1678
	max_damage = 65
	min_broken_damage = 45
	arterial_bleed_severity = 0

/obj/item/organ/external/leg/right/scp1678
	max_damage = 65
	min_broken_damage = 45
	arterial_bleed_severity = 0

/obj/item/organ/external/hand/scp1678
	max_damage = 50
	min_broken_damage = 35
	arterial_bleed_severity = 0
	limb_flags = ORGAN_FLAG_CAN_GRASP

/obj/item/organ/external/hand/right/scp1678
	max_damage = 50
	min_broken_damage = 35
	arterial_bleed_severity = 0
	limb_flags = ORGAN_FLAG_CAN_GRASP

/obj/item/organ/external/foot/scp1678
	max_damage = 50
	min_broken_damage = 35
	arterial_bleed_severity = 0
	limb_flags = ORGAN_FLAG_CAN_STAND

/obj/item/organ/external/foot/right/scp1678
	max_damage = 50
	min_broken_damage = 35
	arterial_bleed_severity = 0
	limb_flags = ORGAN_FLAG_CAN_STAND
