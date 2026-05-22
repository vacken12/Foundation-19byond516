/datum/job/rd
	title = "Директор Исследовательского Отдела"
	department = "Научный отдел"
	department_flag = COM|SCI
	selection_color = "#ad6bad"
	head_position = 1
	total_positions = 1
	spawn_positions = 1
	economic_power = 15
	requirements = list(EXP_TYPE_SCIENCE = 720)
	req_admin_notify = 1
	supervisors = "Директор Зоны"
	minimal_player_age = 20
	ideal_character_age = 40
	spawn_positions = 6
	outfit_type = /decl/hierarchy/outfit/job/command/researchdirector
	class = CLASS_A
	hud_icon = "hudchiefscienceofficer"

	access = list(
		ACCESS_COM_COMMS,
		ACCESS_SCI_COMMS,
		ACCESS_SECURITY_LVL1,
		ACCESS_SECURITY_LVL2,
		ACCESS_SECURITY_LVL3,
		ACCESS_SCIENCE_LVL5,
		ACCESS_SCIENCE_LVL4,
		ACCESS_SCIENCE_LVL3,
		ACCESS_SCIENCE_LVL2,
		ACCESS_SCIENCE_LVL1,
		ACCESS_MEDICAL_LVL1,
		ACCESS_ENGINEERING_LVL1,
		ACCESS_ADMIN_LVL1,
		ACCESS_ADMIN_LVL2,
		ACCESS_ADMIN_LVL3,
		ACCESS_ADMIN_LVL4,
		ACCESS_KEYAUTH,
		ACCESS_RESEARCH,
		ACCESS_ROBOTICS
	)
	minimal_access = list()

	min_skill = list(
	    SKILL_COMPUTER    = SKILL_TRAINED,
	    SKILL_DEVICES     = SKILL_TRAINED,
	    SKILL_SCIENCE     = SKILL_EXPERIENCED
	)

	max_skill = list(
		SKILL_ANATOMY     = SKILL_MASTER,
	    SKILL_DEVICES     = SKILL_MASTER,
	    SKILL_SCIENCE     = SKILL_MASTER
	)

	skill_points = 25
	roleplay_difficulty = "Средняя - Тяжёлая"
	mechanical_difficulty = "Средняя - Тяжёлая"
	duties = "Управляйте Исследовательским отделом. Координируйте эксперименты и технологические разработки."


/*/datum/job/ard
	title = "Помощник Директора Исследовательского Отдела"
	department = "Научный отдел"
	department_flag = COM|SCI
	selection_color = "#ad6bad"
	total_positions = 1
	spawn_positions = 1
	economic_power = 10
	requirements = list(EXP_TYPE_SCIENCE = 620)
	req_admin_notify = 1
	supervisors = "Директор Зоны и Директор Исследовательского Отдела"
	minimal_player_age = 18
	ideal_character_age = 40
	spawn_positions = 6
	outfit_type = /decl/hierarchy/outfit/job/command/aresearchdirector
	class = CLASS_A
	hud_icon = "hudassistantscienceofficer"

	access = list(
		ACCESS_COM_COMMS,
		ACCESS_SCI_COMMS,
		ACCESS_SCIENCE_LVL4,
		ACCESS_SCIENCE_LVL3,
		ACCESS_SCIENCE_LVL2,
		ACCESS_SCIENCE_LVL1,
		ACCESS_MEDICAL_LVL1,
		ACCESS_ENGINEERING_LVL1,
		ACCESS_ADMIN_LVL1,
		ACCESS_ADMIN_LVL2,
		ACCESS_ADMIN_LVL3,
		ACCESS_ADMIN_LVL4,
		ACCESS_KEYAUTH,
		ACCESS_RESEARCH,
		ACCESS_ROBOTICS
	)
	minimal_access = list()

	min_skill = list(
	    SKILL_COMPUTER    = SKILL_BASIC,
	    SKILL_DEVICES     = SKILL_BASIC,
	    SKILL_SCIENCE     = SKILL_BASIC,
		SKILL_ELECTRICAL  = SKILL_BASIC
	)

	max_skill = list(
		SKILL_ANATOMY     = SKILL_MASTER,
	    SKILL_DEVICES     = SKILL_MASTER,
	    SKILL_SCIENCE     = SKILL_MASTER
	)

	skill_points = 12
	roleplay_difficulty = "Лёгкая"
	mechanical_difficulty = "Лёгкая - Средняя"
	duties = "Помогайте Директору Исследовательского Отдела в управлении отделом и проведении экспериментов."*/

/datum/job/seniormentalist
	title = "Старший Исследователь Психотроники"
	department = "Научный отдел"
	department_flag = SCI
	selection_color = "#573757"
	total_positions = 1
	spawn_positions = 1
	supervisors = "Директор Исследовательского Отдела и Помощник Директора Исследовательского Отдела"
	economic_power = 4
	requirements = list(EXP_TYPE_SCIENCE = 620)
	alt_titles = list("Старший Менталист")
	minimal_player_age = 10
	ideal_character_age = 35
	outfit_type = /decl/hierarchy/outfit/job/science/seniormentalist
	class = CLASS_B
	hud_icon = "hudseniorresearcher"

	access = list(
		ACCESS_SCI_COMMS,
		ACCESS_SCIENCE_LVL1,
		ACCESS_SCIENCE_LVL2,
		ACCESS_SCIENCE_LVL3,
		ACCESS_SCIENCE_LVL4,
		ACCESS_MEDICAL_LVL1,
		ACCESS_RESEARCH
	)
	minimal_access = list()

	min_skill = list(
	    SKILL_CHEMISTRY	  = SKILL_TRAINED,
		SKILL_MEDICAL	  = SKILL_TRAINED,
	    SKILL_SCIENCE     = SKILL_EXPERIENCED
	)

	max_skill = list(
		SKILL_CHEMISTRY   = SKILL_MASTER,
	    SKILL_MEDICAL     = SKILL_EXPERIENCED,
	    SKILL_SCIENCE     = SKILL_MASTER
	)

	psi_faculties = list(
		PSI_COERCION = PSI_RANK_OPERANT,
		PSI_PSYCHOKINESIS = PSI_RANK_OPERANT,
		PSI_REDACTION = PSI_RANK_MASTER,
		PSI_ENERGISTICS = PSI_RANK_OPERANT
	)

	skill_points = 20
	roleplay_difficulty = "Средняя - Тяжёлая"
	mechanical_difficulty = "Средняя"

/datum/job/mentalist
	title = "Исследователь Психотроники"
	department = "Научный отдел"
	department_flag = SCI
	selection_color = "#573757"
	total_positions = 2
	spawn_positions = 2
	supervisors = "Старший Исследователь Психотроники, Директор Исследовательского Отдела и Помощник Директора Исследовательского Отдела"
	economic_power = 4
	requirements = list(EXP_TYPE_SCIENCE = 480)
	alt_titles = list("Менталист")
	minimal_player_age = 10
	ideal_character_age = 35
	outfit_type = /decl/hierarchy/outfit/job/science/mentalist
	class = CLASS_C
	hud_icon = "hudseniorresearcher"

	access = list(
		ACCESS_SCI_COMMS,
		ACCESS_SCIENCE_LVL1,
		ACCESS_SCIENCE_LVL2,
		ACCESS_SCIENCE_LVL3,
		ACCESS_MEDICAL_LVL1,
		ACCESS_RESEARCH
	)
	minimal_access = list()

	min_skill = list(
	    SKILL_CHEMISTRY	  = SKILL_BASIC,
		SKILL_MEDICAL	  = SKILL_BASIC,
	    SKILL_SCIENCE     = SKILL_BASIC
	)

	max_skill = list(
		SKILL_CHEMISTRY   = SKILL_EXPERIENCED,
	    SKILL_MEDICAL     = SKILL_EXPERIENCED,
	    SKILL_SCIENCE     = SKILL_MASTER
	)
	psi_faculties = list(
		PSI_COERCION = PSI_RANK_OPERANT) //Basic level of Psionics, with ability to read others.

/datum/job/seniorscientist
	title = "Старший Научный Сотрудник"
	department = "Научный отдел"
	department_flag = SCI
	selection_color = "#633d63"
	total_positions = 3
	spawn_positions = 3
	supervisors = "Директор Исследовательского Отдела и Помощник Директора Исследовательского Отдела"
	economic_power = 4
	requirements = list(EXP_TYPE_SCIENCE = 480)

	alt_titles = list("Старший Ксенобиолог", "Старший Ксеноархеолог", "Старший Ксеноботаник")
	minimal_player_age = 7
	ideal_character_age = 30
	outfit_type = /decl/hierarchy/outfit/job/science/seniorscientist
	class = CLASS_B
	hud_icon = "hudseniorresearcher"

	access = list(
		ACCESS_SCI_COMMS,
		ACCESS_SCIENCE_LVL1,
		ACCESS_SCIENCE_LVL2,
		ACCESS_SCIENCE_LVL3,
		ACCESS_RESEARCH,
		ACCESS_ROBOTICS
	)
	minimal_access = list()

	min_skill = list(
	    SKILL_COMPUTER    = SKILL_BASIC,
	    SKILL_DEVICES     = SKILL_TRAINED,
	    SKILL_SCIENCE     = SKILL_EXPERIENCED
	)

	max_skill = list(
		SKILL_ANATOMY     = SKILL_MASTER,
	    SKILL_DEVICES     = SKILL_MASTER,
	    SKILL_SCIENCE     = SKILL_MASTER
	)

	skill_points = 20

	roleplay_difficulty = "Средняя"
	mechanical_difficulty = "Средняя"
	duties = "Проводите эксперименты и разрабатывайте новые технологии. Управляйте подчинёнными научными сотрудниками."

/datum/job/seniorroboticist
	title = "Старший Техник по Робототехнике"
	department = "Научный отдел"
	department_flag = SCI
	selection_color = "#633d63"
	total_positions = 2
	spawn_positions = 2
	supervisors = "Директор Исследовательского Отдела и Помощник Директора Исследовательского Отдела"
	economic_power = 4
	requirements = list(EXP_TYPE_SCIENCE = 480)
	alt_titles = list("Старший Техник по Экзоскелетам", "Старший Техник по Хардсьютам")
	minimal_player_age = 7
	ideal_character_age = 30
	outfit_type = /decl/hierarchy/outfit/job/science/seniorroboticist
	class = CLASS_B
	hud_icon = "hudseniorresearcher"

	access = list(
		ACCESS_SCI_COMMS,
		ACCESS_SCIENCE_LVL1,
		ACCESS_SCIENCE_LVL2,
		ACCESS_SCIENCE_LVL3,
		ACCESS_ROBOTICS
	)
	minimal_access = list()

	min_skill = list(
	    SKILL_COMPUTER    = SKILL_BASIC,
	    SKILL_DEVICES     = SKILL_TRAINED,
	    SKILL_SCIENCE     = SKILL_TRAINED,
		SKILL_ELECTRICAL  = SKILL_EXPERIENCED,
		SKILL_WEAPONS     = SKILL_BASIC
	)

	max_skill = list(
		SKILL_ANATOMY     = SKILL_MASTER,
	    SKILL_DEVICES     = SKILL_MASTER,
	    SKILL_SCIENCE     = SKILL_MASTER
	)

	skill_points = 18
	roleplay_difficulty = "Средняя"
	mechanical_difficulty = "Средняя"


/datum/job/scientist
	title = "Научный Сотрудник"
	department = "Научный отдел"
	department_flag = SCI
	total_positions = 8
	spawn_positions = 8
	selection_color = "#633d63"
	supervisors = "Директор Исследовательского Отдела и Помощник Директора Исследовательского Отдела"
	economic_power = 4
	requirements = list(EXP_TYPE_SCIENCE = 60)
	alt_titles = list("Ксенобиолог", "Ксеноархеолог", "Ксеноботаник", "Младший Менталист")
	minimal_player_age = 3
	ideal_character_age = 24
	outfit_type = /decl/hierarchy/outfit/job/science/scientist
	class = CLASS_C
	hud_icon = "hudscientist"

	access = list(
	ACCESS_SCI_COMMS,
	ACCESS_RESEARCH,
	ACCESS_SCIENCE_LVL1,
	ACCESS_SCIENCE_LVL2
	)
	minimal_access = list()

	min_skill = list(
	    SKILL_COMPUTER    = SKILL_BASIC,
	    SKILL_DEVICES     = SKILL_BASIC,
	    SKILL_SCIENCE     = SKILL_EXPERIENCED
	)

	max_skill = list(
		SKILL_ANATOMY     = SKILL_MASTER,
	    SKILL_DEVICES     = SKILL_MASTER,
	    SKILL_SCIENCE     = SKILL_MASTER
	)

	skill_points = 15

/datum/job/roboticist
	title = "Техник по Робототехнике"
	department = "Научный отдел"
	department_flag = SCI
	selection_color = "#633d63"
	total_positions = 3
	spawn_positions = 3
	supervisors = "Директор Исследовательского Отдела и Помощник Директора Исследовательского Отдела"
	economic_power = 4
	requirements = list(EXP_TYPE_SCIENCE = 60)
	alt_titles = list("Техник по Экзоскелетам", "Техник по Хардсьютам")
	minimal_player_age = 3
	ideal_character_age = 24
	outfit_type = /decl/hierarchy/outfit/job/science/roboticist
	class = CLASS_C
	hud_icon = "hudscientist"

	access = list(
		ACCESS_SCI_COMMS,
		ACCESS_SCIENCE_LVL1,
		ACCESS_SCIENCE_LVL2,
		ACCESS_ROBOTICS
	)
	minimal_access = list()

	min_skill = list(
	    SKILL_COMPUTER    = SKILL_BASIC,
	    SKILL_DEVICES     = SKILL_TRAINED,
	    SKILL_SCIENCE     = SKILL_BASIC,
		SKILL_ELECTRICAL  = SKILL_TRAINED,
		SKILL_WEAPONS     = SKILL_BASIC
	)

	max_skill = list(
		SKILL_ANATOMY     = SKILL_MASTER,
	    SKILL_DEVICES     = SKILL_MASTER,
	    SKILL_SCIENCE     = SKILL_MASTER
	)
	skill_points = 20
	roleplay_difficulty = "Средняя"
	mechanical_difficulty = "Средняя - Тяжёлая"


/datum/job/juniorscientist
	title = "Младший Научный Сотрудник"
	department = "Научный отдел"
	department_flag = SCI
	selection_color = "#633d63"
	total_positions = 10
	spawn_positions = 10
	supervisors = "Директор Исследовательского Отдела и Помощник Директора Исследовательского Отдела"
	economic_power = 4
	alt_titles = list("Младший Ксенобиолог", "Младший Ксеноархеолог", "Младший Ксеноботаник", "Ассистент Исследователя", "Помощник Исследователя", "Интерн-Исследователь", "Младший Исследователь")
	ideal_character_age = 20
	outfit_type = /decl/hierarchy/outfit/job/science/juniorscientist
	class = CLASS_C
	hud_icon = "hudresearchassistant"

	access = list(
		ACCESS_SCI_COMMS,
		ACCESS_SCIENCE_LVL1
	)
	minimal_access = list()

	min_skill = list(
	    SKILL_COMPUTER    = SKILL_BASIC,
	    SKILL_DEVICES     = SKILL_BASIC,
	    SKILL_SCIENCE     = SKILL_EXPERIENCED
	)

	max_skill = list(
		SKILL_ANATOMY     = SKILL_MASTER,
	    SKILL_DEVICES     = SKILL_MASTER,
	    SKILL_SCIENCE     = SKILL_MASTER
	)
	skill_points = 12
	roleplay_difficulty = "Лёгкая"
	mechanical_difficulty = "Лёгкая - Средняя"
	duties = "Помогайте в проведении экспериментов и технологических разработках."

/datum/job/juniorroboticist
	title = "Младший Техник по Робототехнике"
	department = "Научный отдел"
	department_flag = SCI
	selection_color = "#633d63"
	total_positions = 5
	spawn_positions = 5
	supervisors = "Директор Исследовательского Отдела и Помощник Директора Исследовательского Отдела"
	economic_power = 4
	alt_titles = list("Младший Техник по Экзоскелетам", "Младший Техник по Хардсьютам")
	ideal_character_age = 20
	outfit_type = /decl/hierarchy/outfit/job/science/juniorroboticist
	class = CLASS_C
	hud_icon = "hudresearchassistant"

	access = list(
		ACCESS_SCI_COMMS,
		ACCESS_SCIENCE_LVL1,
		ACCESS_SCIENCE_LVL2,
		ACCESS_ROBOTICS
	)
	minimal_access = list()

	min_skill = list(
	    SKILL_COMPUTER    = SKILL_BASIC,
	    SKILL_DEVICES     = SKILL_BASIC,
	    SKILL_SCIENCE     = SKILL_BASIC,
		SKILL_ELECTRICAL  = SKILL_BASIC
	)

	max_skill = list(
		SKILL_ANATOMY     = SKILL_MASTER,
	    SKILL_DEVICES     = SKILL_MASTER,
	    SKILL_SCIENCE     = SKILL_MASTER
	)

	skill_points = 12
	roleplay_difficulty = "Лёгкая"
	mechanical_difficulty = "Лёгкая - Средняя"
	duties = "Помогайте в проведении экспериментов и технологических разработках."
