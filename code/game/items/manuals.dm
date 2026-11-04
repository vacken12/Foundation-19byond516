/obj/item/book/manual/scp/fra
	name = "Foundation Regulations"
	desc = "A book that has a comprehensive list of Foundation Regulations."
	icon_state = "book1"
	author = "The Internal Security Department"
	title = "Foundation Regulations"

/obj/item/book/manual/scp/fra/Initialize()
	. = ..()
	dat = {"

		<html><head>
		</head>

		<body>
		<iframe width='100%' height='97%' src="http://wiki.scp13.site/index.php?title=Foundation_Regulations&printable=yes&remove_links=1" frameborder="0" id="main_frame"></iframe>
		</body>

		</html>

		"}

/obj/item/book/manual/scp/secsop
	name = "Регуляции"
	desc = "THE book that tells you not to be shit at your job."
	icon_state = "bookSpaceLaw"
	author = "The Internal Security Department"
	title = "СОП Отдела Безопасности"

/obj/item/book/manual/scp/secsop/Initialize()
	. = ..()
	dat = {"

		<html><head>
		</head>

		<body>
		<iframe width='100%' height='97%' src="https://scp13.aperture13.online/wiki/%D0%A0%D0%B5%D0%B3%D1%83%D0%BB%D1%8F%D1%86%D0%B8%D0%B8&printable=yes&remove_links=1" frameborder="0" id="main_frame"></iframe>
		</body>

		</html>

		"}

/obj/item/book/manual/scp/scisop
	name = "Рекомендации по исследованию"
	desc = "THE book that tells you not to be shit at your job."
	icon_state = "analysis"
	author = "The Administrative Department"
	title = "СОП Научного отдела"

/obj/item/book/manual/scp/scisop/Initialize()
	. = ..()
	dat = {"

		<html><head>
		</head>

		<body>
		<iframe width='100%' height='97%' src="https://scp13.aperture13.online/wiki/%D0%A0%D0%B5%D0%BA%D0%BE%D0%BC%D0%B5%D0%BD%D0%B4%D0%B0%D1%86%D0%B8%D0%B8_%D0%BF%D0%BE_%D0%B8%D1%81%D1%81%D0%BB%D0%B5%D0%B4%D0%BE%D0%B2%D0%B0%D0%BD%D0%B8%D1%8E&printable=yes&remove_links=1" frameborder="0" id="main_frame"></iframe>
		</body>

		</html>

		"}

/obj/item/book/manual/scp/medsop
	name = "Руководство по медицине"
	desc = "THE book that tells you not to be shit at your job."
	icon_state = "bookMedical"
	author = "The Administrative Department"
	title = "СОП Медицинского отдела"

/obj/item/book/manual/scp/medsop/Initialize()
	. = ..()
	dat = {"

		<html><head>
		</head>

		<body>
		<iframe width='100%' height='97%' src="https://scp13.aperture13.online/wiki/%D0%A0%D1%83%D0%BA%D0%BE%D0%B2%D0%BE%D0%B4%D1%81%D1%82%D0%B2%D0%BE_%D0%BF%D0%BE_%D0%BC%D0%B5%D0%B4%D0%B8%D1%86%D0%B8%D0%BD%D0%B5&printable=yes&remove_links=1" frameborder="0" id="main_frame"></iframe>
		</body>

		</html>

		"}

/obj/item/book/manual/scp/engsop
	name = "Standard Operating Procedure - Engineering Department"
	desc = "THE book that tells you not to be shit at your job."
	icon_state = "bookParticleAccelerator"
	author = "The Administrative Department"
	title = "Engineering SoP"

/obj/item/book/manual/scp/engsop/Initialize()
	. = ..()
	dat = {"

		<html><head>
		</head>

		<body>
		<iframe width='100%' height='97%' src="http://wiki.scp13.site/index.php?title=Engineering_SOP&printable=yes&remove_links=1" frameborder="0" id="main_frame"></iframe>
		</body>

		</html>

		"}

/obj/item/book/manual/mil_sop
	name = "Military Operating Procedure"
	desc = "SOP in Site 53."
	icon_state = "booksolregs"
	author = "The Foundation"
	title = "Standard Operating Procedure"

/obj/item/book/manual/mil_sop/Initialize()
	. = ..()
	dat = {"

		<html><head>
		</head>

		<body>
		<iframe width='100%' height='97%' src="http://wiki.scp13.site/index.php?title=Security/Military&printable=yes&remove_links=1" frameborder="0" id="main_frame"></iframe>
		</body>

		</html>

		"}

/obj/item/folder/nt/rd

/obj/item/paper/reactor
	name = "Reactor Startup Procedure"
	info = {"
	First, connect up each of the yellow wires. In the image of the R-UST above, you will see red wires connecting the yellow wires from the PACMAN-generator to the SMES, and from the SMES to the fusion core. These are the wires you need to add.<br>
	The fusion core and gyrotron have a heavy power drain when operational. You will need to use the PACMAN to provide this until the fusion process becomes self-sustaining. Insert some tritium ingots from the radioactive crate and turn on the PACMAN with between 0.1MW and 0.15MW of power.<br>
	Create five deuterium and one tritium fuel rod using the fuel compressor and insert these into the fuel injectors, one per injector.<br>
	Return to the control room and raise the chamber containment shutters and ensure that the chamber observation is only down if you are wearing radiation protection gear.<br>
	Set the gyrotron to fire delay 2, power 50. There can be an initial burst in instability when turning the reactor on - If you have allowed fuel to build up. So we set the gyrotron to a high-power mode for the initial startup. Do not walk infront of the gyrotron while it is active.<br>
	Turn on the fusion core and adjust the field strength to 20 tesla.<br>
	Turn on all the fusion fuel injectors.<br>
	Watch the temperature and power rise on the fusion core console. Make sure that the instability is being managed by the gyrotron (less than 1%).<br>
	Once the power output is 250kW or higher, return to the R-UST room and turn off the PACMAN-generator. It may explode if you leave it running for too long.<br>
	You can now adjust the gyrotron power to a lower setting, such as fire delay 3, power output 3. Check that the instability is staying low after adjusting the gyrotron.
	"}

/obj/item/paper/sec_ctp
	name = "Процедуры работы КПП"
	info = {"<center><h1>Процедуры работы КПП</h1></center><br>
	<center><b><font size="4">Фонд - Зона 53</font></b></center><br>
	<center><img src = sec.png></center><br>
	<center><b>Secure. Contain. Protect.</b></center><br>
	<hr>
	<center><b>ЦЕПЬ КОМАНДОВАНИЯ</b><br></center>
	<li>Если Научный Директор недоступен, обратитесь к заместителю Директора по исследованиям.<br>
	<li>Если заместитель Директора по исследованиям недоступен, обратитесь к Директору Зоны.<br>
	<li>Если Директор Зоны недоступен, обратитесь к Командиру Охраны.<br>
	<li>Если Командир Охраны недоступе, то все испытания должны быть приостановлены до дальнейшего уведомления или пробуждения одного из этих трех руководителей персонала.<br>
	<li>Тестирование с объектами класса "Кетер" должно быть приостановлено до тех пор, пока не будут доступны как Директор Зоны, так и Научный Директор.<br>
	<li>Североамериканское командование Фонда доступна в том случае, если для тестирования требуется разрешение и если ни один из трех руководителей персонала недоступен.<br>
	<hr>
	<b>ШАГ ПЕРВЫЙ:</b> Проверьте текущий уровень безопасности на объекте:</b><br>
	<ul><li>ЗЕЛЕНЫЙ КОД: Тестирование должно проводиться в обычном режиме.<br>
	<li>ЖЕЛТЫЙ КОД: Сотрудник контрольно-пропускного пункта может отказаться в проведении тестирования, если существует непосредственная угроза персоналу в соответствующей зоне контрольно-пропускного пункта.<br>
	<li>КРАСНЫЙ КОД: Проведение тестов <b>запрещено</b>. Текущие тесты могут быть прекращены по усмотрению Сержантов Зоны и выше.<br>
	<li>КОД МРАК: Проведение тестов <b>запрещено</b>. Все текущие тесты должны быть завершены как можно скорее.</ul>
	<b>ШАГ ВТОРОЙ: </b>Проверьте подленность предоставленных документов. Если документация неубедительна или поддельна, задержите весь задействованный персонал и сообщите об этом сержантам вашей зоны. В документах должны быть четко указаны SCP и материалы, задействованные в тестировании. Если таковых данных нет, то свяжитесь напрямую с Научным Директором. Вы не имеете права разрешать или не разрешать проведение теста. Старшие научные сотрудники могут проводить тестирование на SCP безопасного уровня по своему усмотрению и не нуждаются в явном одобрении, однако им все равно потребуется оформление документов. SCP класса "Эвклид" требуют подписи и печати Научного Директора. Для SCP класса "Кетер" требуются подписи и штампы Научного Директора и Директора Зоны. Для перекрёстных тестов требуются подписи и штампы Научного Директора и Директора Зоны, а также одобрение Североамериканского Командования Фонда. Однако вы можете отказать в проведении теста в зависимости от уровня тревоги Зоны а также, если тест является неэтичным и/или противоречит правилам, либо если отдельные лица вызывают подозрения. Если эксперимент противоречит процедурам сдерживания SCP, вы должны уведомить об этом Научного Директора и Директора Зоны. Если они недоступны - отклоните тест. Если Научный Директор и Директор Зоны по-прежнему одобряют тест, вы можете разрешить участие. В противном случае исследовательской группе будет запрещено проходить через КПП до тех пор, пока не будут внесены необходимые изменения. После проведения всех проверок вы можете поставить на их документы штамп, подтверждающий их прохождение через контрольно-пропускной пункт.<br>
	<b>ШАГ ТРЕТИЙ: </b>Уведомите Директора Зоны и Научного Директора по электронной почте о любых попытках пройти через контрольно-пропускные пункты для проведения исследований. Укажите тестируемого и SCP а также то, получили ли они разрешение пройти через КПП от персонала контрольно-пропускного пункта. Если вы отказали им вход через КПП, укажите причину в своем электронном письме. Если все документы оформлены приемлемо и ни со стороны Научного Директора, ни со стороны Директора Зоны не возникло возражений, вы можете разрешить персоналу пройти контрольно-пропускной пункт.
	<b>ШАГ ЧЕТВЕРТЫЙ: </b> Если тест проводится на SCP класса "Эвклид" или выше, или с Исследователем присутствует сотрудник класса "Д", его должен сопровождать сотрудник службы безопасности зоны, по одному сотруднику на каждые два сотрудника класса D. Указанный сотрудник зоны должен охранять камеру во время проведения теста. Однако, если персонал не соответствует стандартам, в проведении теста будет отказано до дальнейшего уведомления.<br><br>
	При возвращении весь персонал должен быть еще раз обыскан перед прохождением через контрольно-пропускной пункт, это касается рюкзаков, лабораторных халатов, поясов, а также ботинок и карманов.
	<hr>"}

/obj/item/paper/d_class_guide
	name = "D-CLASS ONLY"
	info = "D-1839 here with a memo to you all, found a way to make some 'homemade' tools with some spare rods and duct tape<br>\
	Just grab some duct tape and put it on a rod as a handle (make sure you do it to ONE ROD ONLY, moron), and you got a good base for a tool<br>\
	Slap a second rod on for some wirecutters, a piece of steel for a good crowbar, or a spoon or a fork for a shovel or a pickaxe<br>\
	Didn't use it when I escaped, but I betya if you use those wirecutters to file down the rod, or that crowbar to pry the rod open, you could make some screwdrivers and wrenches.<br>\
	<br>\
	Well I'm outta here, seeya on the other side"

/obj/item/paper/dcell/assignment
	name = "READ THIS FIRST!"
	info = {"
	<tt><center><b>
	<h3>FOUNDATION SECURITY DIVISION</h3></b>
	</center>
<br>
Congratulations, you're in charge of assignments today!
<br>
<b>Before assigning work detail to anyone, make sure to coordinate with your fellow cell guards and Lieutenant to see if all work places have at least one cell guard overlooking it!</b>
<br>
<br>
<b>As an additional note, there is a maximum of work assignments, which is 6x mining and manual labor, 4 x botany, 3x kitchen, 4x janitorial and 6x mining, making for 17 work places at current time.</b>
<br>
<b>DO NOT EXCEED THE MAXIMUM ALLOWED OF WORKSPACES UNDER THREAT OF IMMEDIATE EMPLOYMENT TERMINATION.</b>
<br>
<br>
<b>Cell guards must not assign access other than the D-Class Work Zones. Doing this will result in immediate employment termination.</b>
<br>
Steps to assign someone to work duty;
<br>
0. Remind all guards that work duty assignment requires them to update their access as well. Ask the Lieutenant to hand out assignments ASAP. Guard assignments go first. D-Cells may be unlocked after.
<br>
1. D-Class are allowed to cite their preference. This does not mean you have to grant them at you.
<br>
2. Ask for the ID Card of the D-Class, and assign the appropriate access. Only one work assignment per D-Class.
<br>
3. Return ID Card to D-Class, and give them instructions on how to get to their area.
<br>
4. Inform guards at work stations of the D-Number that is coming their way, so they do not let in random people.
<br>
<br>
<b>Once you are done with assigning D-Class, or the work assignments are full, close down the shutters and secure the Mastercard in the locker supplied next to your desk. The safe code is 15954. Failure to do this will result in immediate termination.</b>
<br>
<br>
<b>Assigning additional access to yourself besides the Class D work assignments is noted, and logged in the secure logging system of this terminal. Termination will be instant.</b>
<br>
<br>
Good luck on your shift! For further questions, please defer to your Cell Lieutenant. Return this piece of paper to the Guard Lieutenant, or stash it in the safe if one is not around.
"}
