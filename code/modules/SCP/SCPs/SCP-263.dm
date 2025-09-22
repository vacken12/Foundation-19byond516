#define STATE_OFF				(1<<0)
#define STATE_IDLE				(1<<1)
#define STATE_AWAITING_ANSWER	(1<<2)
#define STATE_ASH				(1<<3)
#define STATE_CASH				(1<<4)

/obj/scp263
	name = "old telivision"
	desc = "An old black and white television, but you can't quite tell which model it is. The logo THOMSOM appears at the bottom."
	icon = 'icons/scp/scp-263.dmi'

	icon_state = "off"

	health_current = 50
	health_max = 50

	// Config

	///Our Questions and answers list
	var/list/questions_and_answers = list(
		"Какой SCP имеет консистенцию арахисового масла??" = list("999","Щекоточный  монстр"),
		"Какой SCP может двигаться только тогда, когда на него не смотрят?" = list("173","Статуя"),
		"На какого SCP вы никогда не должны смотреть?" = list("96", "096", "151", "Картина", "Скромник"),
		"От какого SCP можно избавиться??" = list("49", "049", "Чумной доктор", "500"),
		"Какой самый старый SCP на объекте?" = list("173", "Статуя"),
		"Где вы можете найти SCP-151?" = list("ЛЗС", "Легкая Зона Содержания", "Легкая зона содержания", "В Легкой Зоне Содержания", "В легкой зоне содержания"),
		"Какой SCP может проходить сквозь стены?" = list("343", "Бог", "106", "Старик", "Дед"),
		"Какой SCP является поклонником тьмы?" = list("106", "Старик", "Дед", "280", "Глаза"),
		"Какой SCP вечно голоден и ест всё?" = list("682", "Неумирающий", "Ящер", "Древний Ящер"),
		"Какой SCP может стать вашим другом?" = list("131", "Каплеглазик", "Каплеглазики"),
		"Где вы можете найти SCP-096?" = list("ТЗС", "Тяжелая Зона Содержания", "Тяжелая Зона", "Тяжелая зона содержания", "В Тяжелой Зоне Содержания", "В тяжелой зоне содержания"),
		"В какой SCP вы можете забраться?" = list("216", "Сейф", "1102", "Чемодан", "Чемодан-убежище", "Чемодан убежище"),
		"Какой SCP является битой?" = list("2398")
	)
	///Possible rewards (weighted list)
	var/list/rewards = list(
		/obj/item/spacecash/bundle/c1 = 4,
		/obj/item/spacecash/bundle/c10 = 3,
		/obj/item/spacecash/bundle/c20 = 3,
		/obj/item/spacecash/bundle/c50 = 2,
		/obj/item/spacecash/bundle/c100 = 2,
		/obj/item/spacecash/bundle/c1000 = 1,
		/obj/item/stack/material/gold = 2,
		/obj/item/towel/fleece = 1
	)

	// Mechanics

	///Our current contestant
	var/mob/living/carbon/human/contestant
	///Our current state
	var/state = STATE_OFF
	///Our 263-1 Mob
	var/mob/living/carbon/scp263_1/current_scp263_1
	///Our copy of QnA list for use with pick n take
	var/list/questions_and_answers_copy = list()
	///What question we are on
	var/current_question
	///How many questions we have asked
	var/question_count
	///Ref to current question fail callback
	var/question_callback_fail
	///Have we cheated (this avoids message spam)
	var/has_cheated = FALSE

//This lets us talk out of the TV
/mob/living/carbon/scp263_1
	name = "strange man in the tv"
	desc = "A male human of Caucasian descent of approximately thirty-five years of age, dressed in a suit that matches a style commonly worn between the years 1959 and 1964."

	universal_speak = TRUE

/obj/scp263/Initialize()
	. = ..()
	SCP = new /datum/scp(
		src, // Ref to actual SCP atom
		"old telivision", //Name (Should not be the scp desg, more like what it can be described as to viewers)
		SCP_EUCLID, //Obj Class
		"263", //Numerical Designation
	)

	current_scp263_1 = new /mob/living/carbon/scp263_1(src)
	questions_and_answers_copy = questions_and_answers.Copy()

/obj/scp263/Destroy()
	. = ..()
	contestant = null
	qdel(current_scp263_1)

/mob/living/carbon/scp263_1/Initialize()
	. = ..()
	if(!istype(loc, /obj/scp263))
		log_and_message_staff("Instance of SCP-263-1 spawned outside of SCP-263! Queing for deletion!", location = get_turf(src))
		qdel(src)
		return

	SCP = new /datum/scp(
		src, // Ref to actual SCP atom
		"strange man in the tv", //Name (Should not be the scp desg, more like what it can be described as to viewers)
		SCP_EUCLID, //Obj Class
		"263-1", //Numerical Designation
	)

// Mechanics

/obj/scp263/proc/cheated(datum/source, mob/speaker)
	if((speaker && ((speaker == current_scp263_1) || (speaker == contestant))) || has_cheated)
		return

	state = STATE_IDLE
	update_icon()
	has_cheated = TRUE

	current_scp263_1.say(pick("Так-так, жульничаем?", "Пытаемся помочь себе со стороны?", "А честно ответить не судьба?"))
	contestant.fire_stacks++
	contestant?.IgniteMob()
	spawn(10 SECONDS)
		current_scp263_1.say(pick("Что и говорить, мораль нынешнего поколения окончательно разложилась.", "Полагаю,  [contestant.client.p_their()] этика была не так хороша, как я думал.", "Печально, что они оказались совершенно моральными банкротами."))
		contestant.dust()

		reset_target()
		spawn(5 SECONDS)
			reset_state()

/obj/scp263/proc/check_viewer(datum/source)
	if(!(contestant in viewers(world.view, src)))
		cheated()

/obj/scp263/proc/add_contestant(mob/living/carbon/human/new_contestant)
	if(contestant || !istype(new_contestant))
		return
	contestant = new_contestant
	RegisterSignal(contestant, COMSIG_MOB_HEARD_SPEECH, PROC_REF(cheated))
	RegisterSignal(contestant, COMSIG_MOB_HEARD_WHISPER, PROC_REF(cheated))
	RegisterSignal(contestant, COMSIG_MOVED, PROC_REF(check_viewer))

/obj/scp263/proc/reset_target()
	if(!contestant)
		return

	UnregisterSignal(contestant, COMSIG_MOB_HEARD_SPEECH)
	UnregisterSignal(contestant, COMSIG_MOB_HEARD_WHISPER)
	UnregisterSignal(contestant, COMSIG_MOVED)
	contestant = null

/obj/scp263/proc/reset_state()
	current_question = null
	question_count = 0

	deltimer(question_callback_fail)
	question_callback_fail = null

	questions_and_answers_copy = questions_and_answers.Copy()

	has_cheated = FALSE

	state = STATE_OFF
	update_icon()

/obj/scp263/proc/ask_question()
	question_count++

	current_question = pick_n_take(questions_and_answers_copy)
	current_scp263_1.say("[current_question] У вас есть 45 секунд на ответ.")

	state = STATE_AWAITING_ANSWER
	update_icon()

	question_callback_fail = addtimer(CALLBACK(src, PROC_REF(question_fail), TRUE), 45 SECONDS, TIMER_STOPPABLE)

/obj/scp263/proc/question_succeed()
	state = STATE_IDLE
	update_icon()
	if(question_callback_fail)
		deltimer(question_callback_fail)

	if(question_count < 3)
		current_scp263_1.say(pick("Верно!", "Правильно!", "Именно так!", "Точно!", "Да, именно так!", "Отличный ответ!", "Прекрасно сделано!", "Я знал, что ты сможешь!", "Тебе эти вопросы по зубам!"))
		spawn(5 SECONDS)
			current_scp263_1.say(pick("Теперь перейдем к следующему вопросу.", "Вопрос номер [question_count + 1]", "Следующий вопрос..."))
			spawn(5 SECONDS)
				ask_question()
	else
		state = STATE_CASH
		update_icon()
		current_scp263_1.say("Поздравляю! Вы выиграли деньги! Вот ваш приз!")
		var/reward_path = pickweight(rewards)
		var/obj/reward = new reward_path(get_turf(contestant))
		contestant.put_in_active_hand(reward) ? reward.visible_message(SPAN_NOTICE("[reward] materializes right into your hand!")) : reward.visible_message(SPAN_NOTICE("[reward] materializes under you!"))

		reset_target()
		spawn(5 SECONDS)
			reset_state()

/obj/scp263/proc/question_fail(is_timeout = FALSE)
	state = STATE_ASH
	update_icon()
	deltimer(question_callback_fail)
	var/list/message_list = is_timeout ? list("Кажется, у тебя закончилось время!", "Время истекло!", "Времени не осталось!", "Слишком поздно!") : list("Ооо, почти получилось!", "Неверно!", "Это неправильно!", "Нет!", "Хорошая попытка!")
	current_scp263_1.say(pick(message_list))
	contestant.fire_stacks++
	contestant?.IgniteMob()
	spawn(10 SECONDS)
		state = STATE_IDLE
		update_icon()
		current_scp263_1.say("[pick("Очень жаль, мне это очень понравилось.", "Жаль, я думал, что у [M] получится лучше.", "Их неудача - настоящая жалость.")] Посмотрим, удастся ли следующему участнику избежать провала... и сорвать куш!")
		contestant.dust()

		reset_target()
		spawn(8 SECONDS)
			reset_state()

//Overrides

/obj/scp263/hear_talk(mob/M, text, verb, datum/language/speaking)
	if((state != STATE_AWAITING_ANSWER) || (M != contestant))
		return
	for(var/answer in questions_and_answers[current_question])
		if(findtext(text, answer, 1, length(text) + 1))
			question_succeed()
			return
	question_fail()

/obj/scp263/attack_hand(mob/living/carbon/human/M)
	if(!istype(M) || M.a_intent != I_HELP || !is_alive())
		return ..()
	state = STATE_IDLE
	update_icon()

	current_scp263_1.say("Добро пожаловать в Куш... или... Пуш!")
	spawn(5 SECONDS)
		current_scp263_1.say("Поздравляем! [M] Тебе выпал шанс стать следующим участником «Куш или Пуш!»")
	spawn(10 SECONDS)
		current_scp263_1.say("Тебе предстоит ответить на три коварных вопроса! Желаю тебе сорвать куш, а не отправиться в пуш!")
	spawn(15 SECOND)
		current_scp263_1.say("Вопрос номер один!")
	spawn(20 SECOND)
		add_contestant(M)
		ask_question()

/obj/scp263/update_icon()
	switch(state)
		if(STATE_OFF)
			icon_state = "off"
		if(STATE_IDLE)
			icon_state = "on"
		if(STATE_AWAITING_ANSWER)
			icon_state = "animation"
		if(STATE_ASH)
			icon_state = "ash"
		if(STATE_CASH)
			icon_state = "cash"
	return ..()

/obj/scp263/handle_death_change(new_death_state)
	if(new_death_state)
		playsound(src, SFX_SHATTER, 70, 1)
		show_sound_effect(src.loc, soundicon = SFX_ICON_JAGGED)
		visible_message(SPAN_WARNING("\The [src]'s screen shatters!"))

		for(var/i = 1 to rand(1,2))
			new /obj/item/material/shard(get_turf(src))
		icon_state = "broken"
	else
		icon_state = "off"

#undef STATE_OFF
#undef STATE_IDLE
#undef STATE_AWAITING_ANSWER
#undef STATE_ASH
#undef STATE_CASH
