// ============================================
// СЕРВЕР ДОКУМЕНТОВ ДЛЯ ЗОНЫ 53
// ============================================

/obj/item/modular_computer/console/preset/paperwork_dataserver/install_default_programs()
	..()
	var/datum/computer_file/program/upload_database/UD = new()
	hard_drive.store_file(UD)

	turn_on()
	run_program(UD.filename)

	UD.server_name = "Paperwork Database"

	// Загружаем только три нужных шаблона
	var/list/custom_template_types = list(
		/datum/computer_file/data/text/paperwork/zone_permit_custom,
		/datum/computer_file/data/text/paperwork/test_log_custom,
		/datum/computer_file/data/text/paperwork/construction_permit_custom
	)

	for(var/template_type in custom_template_types)
		var/datum/computer_file/data/text/paperwork/doc = new template_type()
		hard_drive.store_file(doc)
		UD.enabled_files += doc.filename
		LAZYADDASSOC(UD.files_required_access, doc.filename, list())

	UD.set_hosting(TRUE)

// ============================================
// БАЗОВЫЙ ТИП ДЛЯ ДОКУМЕНТОВ
// ============================================

/datum/computer_file/data/text/paperwork
	filename = "BuggedFilename"
	stored_data = "Something's bugged out - contact a coder!"

// ============================================
// КАСТОМНЫЕ ШАБЛОНЫ ДЛЯ ЗОНЫ 53
// ============================================

/datum/computer_file/data/text/paperwork/zone_permit_custom
	filename = "Пропуск_через_КПП"
	stored_data = @{"[center][h1]Фонд[/h1][/center]
[b][small][center] Зона 53 [/center][/small][/b]
[center] [seclogo] [/center]
[center] [b] Secure. Contain. Protect. [/b] [/center]
[hr][small][i]РАЗРЕШЕНИЕ ДОЛЖНО БЫТЬ ВЫДАНО ПРИ ВЪЕЗДЕ И ВОЗВРАЩЕНО ПРИ ВЫЕЗДЕ С КОНТРОЛЬНО-ПРОПУСКНОГО ПУНКТА[/i][/small]
Персоналу, выдавшему это разрешение, предоставляется доступ в указанную зону.
[b]Зона[/b]: [field]
[b]Имя работника[/b]: [field]
[b]Должность работника[/b]: [field]
[b]Цель входа[/b]: [field]
[hr][b]Выдавший разрешение на пропуск через КПП[/b]: [field]"}

/datum/computer_file/data/text/paperwork/test_log_custom
	filename = "Журнал_испытаний"
	stored_data = @{"[center] [h1]Журнал испытаний фонда[/h1] [/center]
[b][small][center] Зона 53 [/center][/small][/b]
[center] [scilogo] [/center]
[center] [b] Secure. Contain. Protect. [/b] [/center]
[hr][b]Назначение теста[/b]: [field]
[b]Ведущий научный сотрудник[/b]: [field]
[b]Дополнительные научные сотрудники[/b]: [field]
[b]Дата и время тестирования[/b]: [field]
[b]Объект(ы), участвующие в тесте[/b]: [field]
[b]Использованные материалы[/b]: [field]
[b]Цель теста[/b]: [field]
[hr][b]Примечания[/b]: [field]
[hr][b]Сопутствующие документы[/b]: [field]
[b]Краткий отчёт[/b]: [field]"}

/datum/computer_file/data/text/paperwork/construction_permit_custom
	filename = "Разрешение_на_строительство"
	stored_data = @{"[center] [h1]Разрешение на строительства Фонда[/h1] [/center]
[b][small][center] Зона 53 [/center][/small][/b]
[center] [englogo] [/center]
[center] [b] Secure. Contain. Protect. [/b] [/center]
[b]Ведущий инженер[/b]: [field]
[b]Дополнительные инженеры[/b]: [field]
[b]Описание планируемой постройки[/b]: [field]
[b]Срок строительства[/b]: [field]
[b]Необходимые материалы[/b]: [field]
[hr][b]Подпись или печать руководителя[/b]: [field]"}
