/datum/job/hos
	title = "Командир Охраны"
	head_position = TRUE
	department = "Командование"
	selection_color = "#8e2929"
	department_flag = SEC|COM
	supervisors = "Директор Зоны"
	req_admin_notify = 1
	economic_power = 10
	requirements = list("Младший лейтенант ЛЗС" = 240, "Старший лейтенант ТЗС" = 240, "Супервайзер ВЗ" = 240)
	total_positions = 1
	spawn_positions = 1
	alt_titles = list("Глава Службы Безопасности", "Начальник Охраны")
	minimal_player_age = 15
	ideal_character_age = 35
	outfit_type = /decl/hierarchy/outfit/job/command/cos
	class = CLASS_A
	hud_icon = "hudguardcommander"

	access = list(
		ACCESS_COM_COMMS,
		ACCESS_SEC_COMMS,
		ACCESS_SECURITY_LVL1,
		ACCESS_SECURITY_LVL2,
		ACCESS_SECURITY_LVL3,
		ACCESS_SECURITY_LVL4,
		ACCESS_SECURITY_LVL5,
		ACCESS_ADMIN_LVL1,
		ACCESS_ADMIN_LVL2,
		ACCESS_ADMIN_LVL3,
		ACCESS_ADMIN_LVL4,
		ACCESS_ADMIN_LVL5,
		ACCESS_MEDICAL_LVL1,
		ACCESS_MEDICAL_LVL2,
		ACCESS_MEDICAL_LVL3,
		ACCESS_MEDICAL_LVL4,
		ACCESS_SCIENCE_LVL1,
		ACCESS_SCIENCE_LVL2,
		ACCESS_SCIENCE_LVL3,
		ACCESS_SCIENCE_LVL4,
		ACCESS_ENGINEERING_LVL1,
		ACCESS_ENGINEERING_LVL2,
		ACCESS_KEYAUTH,
		ACCESS_CHAPEL_OFFICE,
		ACCESS_DCLASS_KITCHEN,
		ACCESS_DCLASS_BOTANY,
		ACCESS_DCLASS_MINING,
		ACCESS_DCLASS_JANITORIAL,
		ACCESS_DCLASS_MEDICAL,
		ACCESS_DCLASS_LUXURY,
		ACCESS_CARGO,
		ACCESS_CARGO_BOT,
		ACCESS_MAILSORTING
	)
	minimal_access = list()

	min_skill = list(
	    SKILL_COMBAT      = SKILL_TRAINED,
	    SKILL_WEAPONS     = SKILL_EXPERIENCED,
	    SKILL_HAULING     = SKILL_TRAINED,
		SKILL_COMPUTER	  = SKILL_TRAINED,
	    SKILL_FORENSICS   = SKILL_TRAINED,
	)

	max_skill = list(
		SKILL_COMBAT      = SKILL_MASTER,
	    SKILL_WEAPONS     = SKILL_MASTER,
	    SKILL_FORENSICS   = SKILL_MASTER
	)
	skill_points = 28

	software_on_spawn = list(/datum/computer_file/program/digitalwarrant,
							 /datum/computer_file/program/camera_monitor)

	roleplay_difficulty = "Тяжёлая"
	mechanical_difficulty = "Лёгкая - Средняя"
	duties = "Управляйте всеми тремя ветвями Службы Безопасности. Отслеживайте потенциальные и текущие угрозы (такие как нарушения содержания). Взаимодействуйте с другими отделами для реагирования на эти угрозы."

//##
//ZONE COMMANDERS
//##

/datum/job/ltofficerlcz
	title = "Младший лейтенант ЛЗС"
	department = "Лёгкая Зона Содержания"
	selection_color = "#8e2929"
	department_flag = SEC|LCZ
	total_positions = 1
	spawn_positions = 1
	supervisors = "Командир Охраны"
	economic_power = 4
	requirements = list(EXP_TYPE_LCZ = 720)
	minimal_player_age = 10
	ideal_character_age = 30
	outfit_type = /decl/hierarchy/outfit/job/security/lcz_zone_commander
	class = CLASS_B
	hud_icon = "hudlczcommander"

	access = list(
		ACCESS_SEC_COMMS,
		ACCESS_SECURITY_LVL1,
		ACCESS_SECURITY_LVL2,
		ACCESS_SECURITY_LVL3,
		ACCESS_SECURITY_LVL4,
		ACCESS_ADMIN_LVL1,
		ACCESS_SCIENCE_LVL1,
		ACCESS_SCIENCE_LVL2,
		ACCESS_SCIENCE_LVL3,
		ACCESS_DCLASS_KITCHEN,
		ACCESS_DCLASS_BOTANY,
		ACCESS_DCLASS_MINING,
		ACCESS_DCLASS_JANITORIAL,
		ACCESS_DCLASS_MEDICAL,
		ACCESS_DCLASS_LUXURY,
		ACCESS_CARGO,
		ACCESS_CARGO_BOT,
		ACCESS_MAILSORTING
	)
	minimal_access = list()

	min_skill = list(
	    SKILL_COMPUTER    = SKILL_BASIC,
	    SKILL_COMBAT      = SKILL_EXPERIENCED,
	    SKILL_WEAPONS     = SKILL_TRAINED,
	    SKILL_HAULING     = SKILL_TRAINED,
	    SKILL_FORENSICS   = SKILL_TRAINED
	)

	max_skill = list(
		SKILL_COMBAT      = SKILL_MASTER,
	    SKILL_WEAPONS     = SKILL_MASTER,
	    SKILL_FORENSICS   = SKILL_TRAINED
	)
	skill_points = 25

	roleplay_difficulty = "Средняя - Тяжёлая"
	mechanical_difficulty = "Средняя"
	duties = "Управляйте Лёгкой Зоной Содержания. Отслеживайте потенциальные и текущие бунты и нарушения содержания."

/datum/job/ltofficerhcz
	title = "Старший лейтенант ТЗС"
	department = "Тяжёлая Зона Содержания"
	selection_color = "#8e2929"
	department_flag = SEC|HCZ
	total_positions = 1
	spawn_positions = 1
	supervisors = "Командир Охраны"
	economic_power = 4
	requirements = list(EXP_TYPE_HCZ = 720)
	minimal_player_age = 10
	ideal_character_age = 30
	outfit_type = /decl/hierarchy/outfit/job/security/hcz_zone_commander
	class = CLASS_B
	hud_icon = "hudhczcommander"

	access = list(
		ACCESS_SEC_COMMS,
		ACCESS_SECURITY_LVL1,
		ACCESS_SECURITY_LVL2,
		ACCESS_SECURITY_LVL3,
		ACCESS_SECURITY_LVL4,
		ACCESS_ADMIN_LVL1,
		ACCESS_SCIENCE_LVL1,
		ACCESS_SCIENCE_LVL2,
		ACCESS_SCIENCE_LVL3,
		ACCESS_SCIENCE_LVL4,
		ACCESS_DCLASS_KITCHEN,
		ACCESS_DCLASS_BOTANY,
		ACCESS_DCLASS_MINING,
		ACCESS_DCLASS_JANITORIAL,
		ACCESS_DCLASS_MEDICAL,
		ACCESS_DCLASS_LUXURY,ACCESS_CARGO,
		ACCESS_CARGO_BOT,
		ACCESS_MAILSORTING
	)
	minimal_access = list()

	min_skill = list(
	    SKILL_COMPUTER    = SKILL_BASIC,
	    SKILL_COMBAT      = SKILL_EXPERIENCED,
	    SKILL_WEAPONS     = SKILL_TRAINED,
	    SKILL_HAULING     = SKILL_TRAINED,
	    SKILL_FORENSICS   = SKILL_BASIC
	)

	max_skill = list(
		SKILL_COMBAT      = SKILL_MASTER,
	    SKILL_WEAPONS     = SKILL_MASTER,
	    SKILL_FORENSICS   = SKILL_TRAINED
	)
	skill_points = 25

	roleplay_difficulty = "Средняя - Тяжёлая"
	mechanical_difficulty = "Средняя"
	duties = "Управляйте Тяжёлой Зоной Содержания. Отслеживайте потенциальные и текущие нарушения содержания."

/datum/job/ltofficerez
	title = "Супервайзер ВЗ"
	department = "Входная Зона"
	selection_color = "#8e2929"
	department_flag = SEC|ECZ
	total_positions = 1
	spawn_positions = 1
	supervisors = "Командир Охраны"
	economic_power = 4
	requirements = list(EXP_TYPE_ECZ = 720)
	minimal_player_age = 10
	ideal_character_age = 27
	outfit_type = /decl/hierarchy/outfit/job/security/ez_zone_commander
	class = CLASS_B
	hud_icon = "hudezcommander"

	access = list(
		ACCESS_SEC_COMMS,
		ACCESS_SECURITY_LVL1,
		ACCESS_SECURITY_LVL2,
		ACCESS_SECURITY_LVL3,
		ACCESS_SECURITY_LVL4,
		ACCESS_ADMIN_LVL1,
		ACCESS_ADMIN_LVL2,
		ACCESS_ADMIN_LVL3,
		ACCESS_ADMIN_LVL4,
		ACCESS_SCIENCE_LVL1,
		ACCESS_SCIENCE_LVL2,
		ACCESS_ENGINEERING_LVL1,
		ACCESS_ENGINEERING_LVL2,
		ACCESS_MEDICAL_LVL1,
		ACCESS_MEDICAL_LVL2,
		ACCESS_MEDICAL_LVL3,
		ACCESS_MEDICAL_LVL4,
		ACCESS_CHAPEL_OFFICE,
		ACCESS_DCLASS_KITCHEN,
		ACCESS_DCLASS_BOTANY,
		ACCESS_DCLASS_MINING,
		ACCESS_DCLASS_JANITORIAL,
		ACCESS_DCLASS_MEDICAL,
		ACCESS_DCLASS_LUXURY,
		ACCESS_CARGO,
		ACCESS_CARGO_BOT,
		ACCESS_MAILSORTING
	)
	minimal_access = list()

	min_skill = list(
	    SKILL_HAULING     = SKILL_TRAINED,
	    SKILL_COMPUTER    = SKILL_TRAINED,
	    SKILL_COMBAT      = SKILL_TRAINED,
	    SKILL_WEAPONS     = SKILL_EXPERIENCED,
	    SKILL_FORENSICS   = SKILL_MASTER
	)

	max_skill = list(
		SKILL_COMBAT      = SKILL_MASTER,
	    SKILL_WEAPONS     = SKILL_MASTER,
	    SKILL_FORENSICS   = SKILL_MASTER
	)
	skill_points = 25

	roleplay_difficulty = "Средняя - Тяжёлая"
	mechanical_difficulty = "Средняя"
	duties = "Управляйте Входной Зоной. Обеспечивайте безопасность всего административного персонала, особенно во время нарушений содержания."

//##
// OFFICERS
//##

/datum/job/raisa
	title = "Агент АПАИБ"
	department = "Входная Зона"
	selection_color = "#601c1c"
	department_flag = SEC|ECZ|BUR
	total_positions = 1
	spawn_positions = 1
	supervisors = "Супервайзер ВЗ"
	economic_power = 5
	requirements = list(EXP_TYPE_COMMAND = 120, EXP_TYPE_SECURITY = 180, EXP_TYPE_ENGINEERING = 90, EXP_TYPE_BUR = 60)
	alt_titles = list()
	minimal_player_age = 7
	ideal_character_age = 25
	outfit_type = /decl/hierarchy/outfit/job/security/raisa_agent
	class = CLASS_B
	hud_icon = "hudraisa"

	access = list(
		ACCESS_ENG_COMMS,
		ACCESS_SEC_COMMS,
		ACCESS_SCIENCE_LVL1,
		ACCESS_MEDICAL_LVL1,
		ACCESS_ENGINEERING_LVL1,
		ACCESS_ENGINEERING_LVL2,
		ACCESS_SECURITY_LVL1,
		ACCESS_SECURITY_LVL2,
		ACCESS_SECURITY_LVL3,
		ACCESS_ADMIN_LVL1,
		ACCESS_ADMIN_LVL2,
		ACCESS_ADMIN_LVL3,
		ACCESS_NETWORK,
		ACCESS_DCLASS_KITCHEN,
		ACCESS_DCLASS_BOTANY,
		ACCESS_DCLASS_MINING,
		ACCESS_DCLASS_JANITORIAL,
		ACCESS_DCLASS_MEDICAL,
		ACCESS_DCLASS_LUXURY
	)
	minimal_access = list()

	min_skill = list(
	    SKILL_COMPUTER    = SKILL_EXPERIENCED,
	    SKILL_FORENSICS   = SKILL_TRAINED
	)

	max_skill = list(
	    SKILL_COMPUTER    = SKILL_MASTER,
	    SKILL_FORENSICS   = SKILL_EXPERIENCED
	)
	skill_points = 17

	roleplay_difficulty = "Средняя - Тяжёлая"
	mechanical_difficulty = "Средняя"
	duties = "Отслеживайте и предотвращайте потенциальный шпионаж. Контролируйте доступ к секретной информации. Защищайте базы данных SCP от угроз, как обычных, так и аномальных."

/datum/job/ncoofficerlcz
	title = "Сержант ЛЗС"
	department = "Лёгкая Зона Содержания"
	selection_color = "#601c1c"
	department_flag = SEC|LCZ
	total_positions = 2
	spawn_positions = 2
	balance_limited = TRUE
	supervisors = "Лейтенант зоны ЛЗС"
	economic_power = 4
	requirements = list(EXP_TYPE_LCZ = 480)
	alt_titles = list("Старший боевой медик ЛЗС" = /decl/hierarchy/outfit/job/security/lcz_medic, "Старший боец отряда подавления беспорядков ЛЗС" = /decl/hierarchy/outfit/job/security/lcz_riot)
	minimal_player_age = 5
	ideal_character_age = 25
	outfit_type = /decl/hierarchy/outfit/job/security/lcz_sergeant
	class = CLASS_C
	hud_icon = "hudlczsarge"

	access = list(
		ACCESS_SEC_COMMS,
		ACCESS_SECURITY_LVL1,
		ACCESS_SECURITY_LVL2,
		ACCESS_SECURITY_LVL3,
		ACCESS_SCIENCE_LVL1,
		ACCESS_SCIENCE_LVL2,
		ACCESS_DCLASS_KITCHEN,
		ACCESS_DCLASS_BOTANY,
		ACCESS_DCLASS_MINING,
		ACCESS_DCLASS_JANITORIAL,
		ACCESS_DCLASS_MEDICAL,
		ACCESS_DCLASS_LUXURY
	)
	minimal_access = list()

	min_skill = list(
	    SKILL_COMPUTER    = SKILL_BASIC,
	    SKILL_HAULING     = SKILL_TRAINED,
	    SKILL_COMBAT      = SKILL_TRAINED,
	    SKILL_WEAPONS     = SKILL_TRAINED,
	    SKILL_FORENSICS   = SKILL_BASIC
	)

	max_skill = list(
		SKILL_COMBAT      = SKILL_EXPERIENCED,
	    SKILL_WEAPONS     = SKILL_EXPERIENCED,
	    SKILL_FORENSICS   = SKILL_TRAINED
	)
	skill_points = 21

/datum/job/ncoofficerhcz
	title = "Сержант ТЗС"
	department = "Тяжёлая Зона Содержания"
	selection_color = "#601c1c"
	department_flag = SEC|HCZ
	total_positions = 2
	spawn_positions = 2
	supervisors = "Лейтенант зоны ТЗС"
	economic_power = 4
	requirements = list(EXP_TYPE_HCZ = 480)
	alt_titles = list("Старший агент реагирования на нарушения ТЗС", "Сержант реагирования на нарушения ТЗС", "Старший боевой медик ТЗС", "Старший агент ТЗС")
	minimal_player_age = 5
	ideal_character_age = 25
	outfit_type = /decl/hierarchy/outfit/job/security/hcz_sergeant
	class = CLASS_C
	hud_icon = "hudhczsarge"

	access = list(
		ACCESS_SEC_COMMS,
		ACCESS_SECURITY_LVL1,
		ACCESS_SECURITY_LVL2,
		ACCESS_SECURITY_LVL3,
		ACCESS_SCIENCE_LVL1,
		ACCESS_SCIENCE_LVL2,
		ACCESS_SCIENCE_LVL3
	)
	minimal_access = list()

	min_skill = list(
	    SKILL_HAULING     = SKILL_TRAINED,
	    SKILL_COMPUTER    = SKILL_BASIC,
	    SKILL_COMBAT      = SKILL_TRAINED,
	    SKILL_WEAPONS     = SKILL_TRAINED,
	    SKILL_FORENSICS   = SKILL_BASIC
	)

	max_skill = list(
		SKILL_COMBAT      = SKILL_MASTER,
	    SKILL_WEAPONS     = SKILL_MASTER,
	    SKILL_FORENSICS   = SKILL_TRAINED
	)
	skill_points = 21

/datum/job/ncoofficerez
	title = "Старший агент ВЗ"
	department = "Входная Зона"
	selection_color = "#601c1c"
	department_flag = SEC|ECZ
	total_positions = 2
	spawn_positions = 2
	supervisors = "Супервайзер зоны ВЗ"
	economic_power = 4
	requirements = list(EXP_TYPE_ECZ = 480)
	alt_titles = list("Офицер расследований" = /decl/hierarchy/outfit/job/security/ez_sergeant_investigative, "Старший боевой медик ВЗ" = /decl/hierarchy/outfit/job/security/ez_medic)
	minimal_player_age = 5
	ideal_character_age = 25
	outfit_type = /decl/hierarchy/outfit/job/security/ez_sergeant
	class = CLASS_C
	hud_icon = "hudezsarge"

	access = list(
		ACCESS_SEC_COMMS,
		ACCESS_SCIENCE_LVL1,
		ACCESS_MEDICAL_LVL1,
		ACCESS_MEDICAL_LVL2,
		ACCESS_MEDICAL_LVL3,
		ACCESS_ENGINEERING_LVL1,
		ACCESS_SECURITY_LVL1,
		ACCESS_SECURITY_LVL2,
		ACCESS_SECURITY_LVL3,
		ACCESS_ADMIN_LVL1,
		ACCESS_ADMIN_LVL2,
		ACCESS_ADMIN_LVL3,
		ACCESS_CHAPEL_OFFICE
	)
	minimal_access = list()

	min_skill = list(
	    SKILL_COMPUTER    = SKILL_TRAINED,
	    SKILL_COMBAT      = SKILL_TRAINED,
	    SKILL_WEAPONS     = SKILL_TRAINED,
	    SKILL_FORENSICS   = SKILL_EXPERIENCED
	)

	max_skill = list(
		SKILL_COMBAT      = SKILL_EXPERIENCED,
	    SKILL_WEAPONS     = SKILL_EXPERIENCED,
	    SKILL_FORENSICS   = SKILL_MASTER
	)
	skill_points = 21
//##
//JUNIOR OFFICER
//##

/datum/job/enlistedofficerlcz

	title = "Охранник ЛЗС"
	department = "Лёгкая Зона Содержания"
	selection_color = "#601c1c"
	department_flag = SEC|LCZ
	total_positions = 8
	spawn_positions = 8
	supervisors = "Сержанты ЛЗС и Лейтенант зоны"
	economic_power = 4
	requirements = list(EXP_TYPE_LCZ = 220)
	alt_titles = list("Боевой медик ЛЗС" = /decl/hierarchy/outfit/job/security/lcz_medic, "Боец отряда подавления беспорядков ЛЗС" = /decl/hierarchy/outfit/job/security/lcz_riot)
	minimal_player_age = 0
	ideal_character_age = 25
	balance_limited = TRUE
	outfit_type = /decl/hierarchy/outfit/job/security/lcz_guard
	class = CLASS_C
	hud_icon = "hudlczsenior"

	access = list(
		ACCESS_SEC_COMMS,
		ACCESS_SECURITY_LVL1,
		ACCESS_SECURITY_LVL2,
		ACCESS_SCIENCE_LVL1,
		ACCESS_SCIENCE_LVL2,
		ACCESS_DCLASS_KITCHEN,
		ACCESS_DCLASS_BOTANY,
		ACCESS_DCLASS_MINING,
		ACCESS_DCLASS_JANITORIAL,
		ACCESS_DCLASS_MEDICAL,
		ACCESS_DCLASS_LUXURY
	)
	minimal_access = list()

	min_skill = list(
	    SKILL_COMPUTER    = SKILL_BASIC,
	    SKILL_HAULING     = SKILL_TRAINED,
	    SKILL_COMBAT      = SKILL_TRAINED,
	    SKILL_WEAPONS     = SKILL_BASIC,
	    SKILL_FORENSICS   = SKILL_BASIC
	)

	max_skill = list(
		SKILL_COMBAT      = SKILL_EXPERIENCED,
	    SKILL_WEAPONS     = SKILL_EXPERIENCED,
	    SKILL_FORENSICS   = SKILL_TRAINED
	)
	skill_points = 17

/datum/job/lcz_medicaldoctor
	title = "Врач ЛЗС"
	department = "Лёгкая Зона Содержания"
	selection_color = "#601c1c"
	department_flag = SEC|LCZ
	total_positions = 1
	spawn_positions = 1
	supervisors = "Сержанты ЛЗС и Лейтенант зоны"
	economic_power = 4
	requirements = list(EXP_TYPE_LCZ = 480)
	alt_titles = list()
	minimal_player_age = 0
	ideal_character_age = 25
	balance_limited = TRUE
	outfit_type = /decl/hierarchy/outfit/job/lcz_medicaldoctor
	class = CLASS_C
	hud_icon = "hudlczmedicaldoctor"

	access = list(
		ACCESS_SEC_COMMS,
		ACCESS_SECURITY_LVL1,
		ACCESS_SECURITY_LVL2,
		ACCESS_SCIENCE_LVL1,
		ACCESS_SCIENCE_LVL2,
		ACCESS_MED_COMMS,
		ACCESS_MEDICAL_EQUIP,
		ACCESS_MEDICAL_LVL1,
		ACCESS_MEDICAL_LVL2,
		ACCESS_MEDICAL_LVL3,
		ACCESS_DCLASS_KITCHEN,
		ACCESS_DCLASS_BOTANY,
		ACCESS_DCLASS_MINING,
		ACCESS_DCLASS_JANITORIAL,
		ACCESS_DCLASS_MEDICAL,
		ACCESS_DCLASS_LUXURY
	)
	minimal_access = list()

	min_skill = list(
	    SKILL_COMPUTER    = SKILL_BASIC,
	    SKILL_HAULING     = SKILL_TRAINED,
	    SKILL_COMBAT      = SKILL_BASIC,
	    SKILL_WEAPONS     = SKILL_BASIC,
		SKILL_FORENSICS   = SKILL_BASIC,
	    SKILL_MEDICAL     = SKILL_TRAINED,
	    SKILL_ANATOMY     = SKILL_TRAINED,
		SKILL_CHEMISTRY   = SKILL_BASIC,
		SKILL_DEVICES     = SKILL_TRAINED,
		SKILL_SCIENCE     = SKILL_BASIC
	)

	max_skill = list(
		SKILL_COMBAT      = SKILL_TRAINED,
	    SKILL_WEAPONS     = SKILL_TRAINED,
	    SKILL_FORENSICS   = SKILL_TRAINED,
		SKILL_MEDICAL     = SKILL_EXPERIENCED,
	    SKILL_ANATOMY     = SKILL_EXPERIENCED,
	    SKILL_CHEMISTRY   = SKILL_EXPERIENCED
	)
	skill_points = 25

/datum/job/enlistedofficerhcz
	title = "Охранник ТЗС"
	department = "Тяжёлая Зона Содержания"
	selection_color = "#601c1c"
	department_flag = SEC|HCZ
	total_positions = 6
	spawn_positions = 6
	supervisors = "Сержанты ТЗС и Лейтенант зоны"
	economic_power = 4
	requirements = list(EXP_TYPE_HCZ = 220)
	alt_titles = list("Агент реагирования на нарушения ТЗС", "Охранник реагирования на нарушения ТЗС", "Боевой медик ТЗС", "Агент ТЗС")
	minimal_player_age = 0
	ideal_character_age = 25
	outfit_type = /decl/hierarchy/outfit/job/security/hcz_guard
	class = CLASS_C
	hud_icon = "hudhczsenior"

	access = list(
		ACCESS_SEC_COMMS,
		ACCESS_SECURITY_LVL1,
		ACCESS_SECURITY_LVL2,
		ACCESS_SECURITY_LVL3,
		ACCESS_SCIENCE_LVL1,
		ACCESS_SCIENCE_LVL2,
		ACCESS_SCIENCE_LVL3
	)
	minimal_access = list()

	min_skill = list(
	    SKILL_COMPUTER    = SKILL_BASIC,
	    SKILL_HAULING     = SKILL_TRAINED,
	    SKILL_COMBAT      = SKILL_TRAINED,
	    SKILL_WEAPONS     = SKILL_BASIC,
	    SKILL_FORENSICS   = SKILL_BASIC
	)

	max_skill = list(
		SKILL_COMBAT      = SKILL_EXPERIENCED,
	    SKILL_WEAPONS     = SKILL_EXPERIENCED,
	    SKILL_FORENSICS   = SKILL_TRAINED
	)
	skill_points = 17

/datum/job/enlistedofficerez

	title = "Агент ВЗ"
	department = "Входная Зона"
	selection_color = "#601c1c"
	department_flag = SEC|ECZ
	total_positions = 6
	spawn_positions = 6
	supervisors = "Старшие агенты ВЗ и Супервайзер зоны"
	economic_power = 4
	requirements = list(EXP_TYPE_ECZ = 220)
	alt_titles = list("Агент расследований" = /decl/hierarchy/outfit/job/security/ez_guard_investigative, "Боевой медик ВЗ" = /decl/hierarchy/outfit/job/security/ez_medic)
	minimal_player_age = 0
	ideal_character_age = 25
	outfit_type = /decl/hierarchy/outfit/job/security/ez_guard
	class = CLASS_C
	hud_icon = "hudezsenior"

	access = list(
		ACCESS_SCIENCE_LVL1,
		ACCESS_SEC_COMMS,
		ACCESS_SECURITY_LVL1,
		ACCESS_SECURITY_LVL2,
		ACCESS_ENGINEERING_LVL1,
		ACCESS_MEDICAL_LVL1,
		ACCESS_MEDICAL_LVL2,
		ACCESS_MEDICAL_LVL3,
		ACCESS_ADMIN_LVL1,
		ACCESS_ADMIN_LVL2,
		ACCESS_CHAPEL_OFFICE
	)
	minimal_access = list()

	min_skill = list(
	    SKILL_COMPUTER    = SKILL_BASIC,
	    SKILL_HAULING     = SKILL_TRAINED,
	    SKILL_COMBAT      = SKILL_BASIC,
	    SKILL_WEAPONS     = SKILL_TRAINED,
	    SKILL_FORENSICS   = SKILL_EXPERIENCED
	)

	max_skill = list(
		SKILL_COMBAT      = SKILL_EXPERIENCED,
	    SKILL_WEAPONS     = SKILL_EXPERIENCED,
	    SKILL_FORENSICS   = SKILL_MASTER
	)
	skill_points = 17

/datum/job/guardlcz
	title = "Кадет ЛЗС"
	department = "Лёгкая Зона Содержания"
	selection_color = "#601c1c"
	department_flag = SEC|LCZ
	total_positions = 6
	spawn_positions = 6
	supervisors = "Охрана ЛЗС и Лейтенант зоны"
	economic_power = 4
	minimal_player_age = 0
	ideal_character_age = 25
	balance_limited = TRUE
	outfit_type = /decl/hierarchy/outfit/job/security/lcz_cadet
	class = CLASS_C
	hud_icon = "hudlczguard"

	access = list(
		ACCESS_SEC_COMMS,
		ACCESS_SECURITY_LVL1,
		ACCESS_SCIENCE_LVL1,
		ACCESS_SCIENCE_LVL2,
		ACCESS_DCLASS_KITCHEN,
		ACCESS_DCLASS_BOTANY,
		ACCESS_DCLASS_MINING,
		ACCESS_DCLASS_JANITORIAL,
		ACCESS_DCLASS_MEDICAL,
		ACCESS_DCLASS_LUXURY
	)
	minimal_access = list()

	min_skill = list(
	    SKILL_COMPUTER    = SKILL_BASIC,
	    SKILL_HAULING     = SKILL_TRAINED,
	    SKILL_COMBAT      = SKILL_TRAINED,
	    SKILL_WEAPONS     = SKILL_BASIC,
	    SKILL_FORENSICS   = SKILL_BASIC
	)

	max_skill = list(
		SKILL_COMBAT      = SKILL_EXPERIENCED,
	    SKILL_WEAPONS     = SKILL_EXPERIENCED,
	    SKILL_FORENSICS   = SKILL_TRAINED
	)
	skill_points = 15

/datum/job/guardhcz
	title = "Рядовой ТЗС"
	department = "Тяжёлая Зона Содержания"
	selection_color = "#601c1c"
	department_flag = SEC|HCZ
	total_positions = 6
	spawn_positions = 6
	supervisors = "Охрана ТЗС и Лейтенант зоны"
	economic_power = 4
	ideal_character_age = 25
	outfit_type = /decl/hierarchy/outfit/job/security/hcz_cadet
	class = CLASS_C
	hud_icon = "hudhczguard"

	access = list(
		ACCESS_SEC_COMMS,
		ACCESS_SECURITY_LVL1,
		ACCESS_SECURITY_LVL2,
		ACCESS_SECURITY_LVL3,
		ACCESS_SCIENCE_LVL1,
		ACCESS_SCIENCE_LVL2
	)
	minimal_access = list()

	min_skill = list(
	    SKILL_COMPUTER    = SKILL_BASIC,
	    SKILL_HAULING     = SKILL_TRAINED,
	    SKILL_COMBAT      = SKILL_TRAINED,
	    SKILL_WEAPONS     = SKILL_BASIC,
	    SKILL_FORENSICS   = SKILL_BASIC
	)

	max_skill = list(
		SKILL_COMBAT      = SKILL_EXPERIENCED,
	    SKILL_WEAPONS     = SKILL_EXPERIENCED,
	    SKILL_FORENSICS   = SKILL_TRAINED
	)
	skill_points = 15

/datum/job/guardez
	title = "Стажёр-агент ВЗ"
	department = "Входная Зона"
	selection_color = "#601c1c"
	department_flag = SEC|ECZ
	total_positions = 6
	spawn_positions = 6
	supervisors = "Охрана ВЗ и Супервайзер зоны"
	economic_power = 4
	minimal_player_age = 0
	ideal_character_age = 25
	outfit_type = /decl/hierarchy/outfit/job/security/ez_probationary
	class = CLASS_C
	hud_icon = "hudezguard"

	access = list(
		ACCESS_SCIENCE_LVL1,
		ACCESS_SEC_COMMS,
		ACCESS_SECURITY_LVL1,
		ACCESS_SECURITY_LVL2,
		ACCESS_ENGINEERING_LVL1,
		ACCESS_MEDICAL_LVL1,
		ACCESS_MEDICAL_LVL2,
		ACCESS_MEDICAL_LVL3,
		ACCESS_ADMIN_LVL1,
		ACCESS_CHAPEL_OFFICE
	)
	minimal_access = list()

	min_skill = list(
	    SKILL_COMPUTER    = SKILL_BASIC,
	    SKILL_HAULING     = SKILL_TRAINED,
	    SKILL_COMBAT      = SKILL_BASIC,
	    SKILL_WEAPONS     = SKILL_TRAINED,
	    SKILL_FORENSICS   = SKILL_EXPERIENCED
	)

	max_skill = list(
		SKILL_COMBAT      = SKILL_TRAINED,
	    SKILL_WEAPONS     = SKILL_EXPERIENCED,
	    SKILL_FORENSICS   = SKILL_EXPERIENCED
	)
	skill_points = 15
