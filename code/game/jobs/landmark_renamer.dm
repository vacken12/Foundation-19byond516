// Автоматический перевод названий стартовых ландмарок профессий на русский язык
// при старте сервера. Карту можно не трогать.

/hook/startup/proc/translate_job_landmarks()
	var/list/name_map = list(
		"Site Director" = "Директор Зоны",
		"Site Manager" = "Менеджер Зоны",
		"Communications Officer" = "Офицер коммуникации",
		"Internal Tribunal Department Officer" = "Офицер Внутреннего Трибунала",
		"Ethics Committee Liaison" = "Представитель Комитета по Этике",
		"Global Occult Coalition Representative" = "Представитель Глобальной Оккультной Коалиции",
		"Engineering Director" = "Директор Инженерного Отдела",
		"Senior Engineer" = "Старший Инженер",
		"Engineer" = "Инженер",
		"Junior Engineer" = "Младший Инженер",
		"IT Technician" = "IT-Техник",
		"Medical Director" = "Директор Медицинского Отдела",
		"Surgeon" = "Хирург",
		"Chemist" = "Химик",
		"Psychiatrist" = "Психиатр",
		"Medical Doctor" = "Врач",
		"Emergency Medical Technician" = "Техник Скорой Медицинской Помощи",
		"Medical Intern" = "Медицинский Интерн",
		"Research Director" = "Директор Исследовательского Отдела",
		"Senior Psychotronics Researcher" = "Старший Исследователь Психотроники",
		"Psychotronics Researcher" = "Исследователь Психотроники",
		"Senior Researcher" = "Старший Научный Сотрудник",
		"Senior Robotics Technician" = "Старший Техник по Робототехнике",
		"Researcher" = "Научный Сотрудник",
		"Robotics Technician" = "Техник по Робототехнике",
		"Researcher Associate" = "Младший Научный Сотрудник",
		"Junior Robotics Technician" = "Младший Техник по Робототехнике",
		"Guard Commander" = "Командир Охраны",
		"LCZ Zone Junior Lieutenant" = "Младший лейтенант ЛЗС",
		"HCZ Zone Senior Lieutenant" = "Старший лейтенант ТЗС",
		"EZ Zone Supervisor" = "Супервайзер ВЗ",
		"RAISA Agent" = "Агент АПАИБ",
		"LCZ Sergeant" = "Сержант ЛЗС",
		"HCZ Sergeant" = "Сержант ТЗС",
		"EZ Senior Agent" = "Старший агент ВЗ",
		"LCZ Guard" = "Охранник ЛЗС",
		"LCZ Medical Doctor" = "Врач ЛЗС",
		"HCZ Guard" = "Охранник ТЗС",
		"EZ Agent" = "Агент ВЗ",
		"LCZ Cadet" = "Кадет ЛЗС",
		"HCZ Private" = "Рядовой ТЗС",
		"EZ Probationary Agent" = "Стажёр-агент ВЗ",
		"Class D" = "Класс D",
		"Logistics Officer" = "Офицер Логистики",
		"Logistics Specialist" = "Специалист по логистике",
		"Office Worker" = "Офисный работник",
		"Janitor" = "Уборщик",
		"Chef" = "Шеф-повар",
		"Bartender" = "Бармен",
		"Chaplain" = "Священник",
		"AIC" = "ИИ",
		"Robot" = "Робот",
		// Закоменченные должности:
		"Communications Technician" = "Коммуникационный техник",
		"Assistant Engineering Director" = "Помощник Директора Инженерного Отдела",
		"Containment Engineer" = "Инженер по Содержанию",
		"Assistant Medical Director" = "Помощник Директора Медицинского Отдела",
		"Assistant Research Director" = "Помощник Директора Исследовательского Отдела"
	)

	for(var/obj/effect/landmark/start/L in landmarks_list)
		if(L.name in name_map)
			L.name = name_map[L.name]
	return TRUE
