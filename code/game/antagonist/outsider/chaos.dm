var/global/list/chaos_recruited = list()
var/global/chaos_triggered = 0

GLOBAL_DATUM_INIT(chaos, /datum/antagonist/chaos, new)

/datum/antagonist/chaos
	id = "chaos"
	role_text = "Chaos Insurgent"
	role_text_plural = "Chaos Insurgents"
	welcome_text = "You have become a Chaos Insurgent!"
	antag_text = "Primary objective: full capture of the facility and establishing control over all key zones. Neutralize all hostile SCP objects that pose a threat. Suppress any resistance from Foundation personnel. Take prisoners when possible, especially among key personnel — they may provide valuable information."
	landmark_id = "Chaos_Spawn"
	id_type = /obj/item/card/id/chaos

	flags = ANTAG_OVERRIDE_JOB | ANTAG_HAS_LEADER | ANTAG_CLEAR_EQUIPMENT
	antaghud_indicator = "hudsyndicate"

	hard_cap = 10
	hard_cap_round = 15
	initial_spawn_req = 0
	initial_spawn_target = 0
	show_objectives_on_creation = 1
	faction = "chaos"

	var/reason = ""

	var/agent_outfit = /decl/hierarchy/outfit/chaos/soldier
	var/heavy_outfit = /decl/hierarchy/outfit/chaos/heavy_soldier
	var/leader_outfit = /decl/hierarchy/outfit/chaos/leader

	var/list/class_outfits = list(
		"Soldier" = /decl/hierarchy/outfit/chaos/soldier,
		"Heavy" = /decl/hierarchy/outfit/chaos/heavy_soldier
	)

/datum/antagonist/chaos/New()
	..()
	if(leader_welcome_text == initial(leader_welcome_text))
		leader_welcome_text = "As the leader of the Chaos Insurgency, you are responsible for coordinating the squad and completing the mission."

/datum/antagonist/chaos/greet(datum/mind/player)
	if(!..())
		return
	if(player == leader)
		to_chat(player.current, "You are the squad leader. Coordinate your squad and lead them to victory!")

/datum/antagonist/chaos/equip(mob/living/carbon/human/player)
	player.add_language(LANGUAGE_ENGLISH)

	var/outfit_to_use
	if(leader && player.mind == leader && leader_outfit)
		outfit_to_use = leader_outfit
	else if(player.ckey in chaos_recruited)
		if(prob(25))
			outfit_to_use = heavy_outfit
		else
			outfit_to_use = agent_outfit
	else
		var/chosen_class = input(player, "Choose your specialization:", "Chaos Class Selection") as null|anything in class_outfits
		if(chosen_class)
			outfit_to_use = class_outfits[chosen_class]
		else
			outfit_to_use = agent_outfit

	if(outfit_to_use)
		dressup_human(player, outfits_decls_by_type_[outfit_to_use], TRUE)
	else
		dressup_human(player, outfits_decls_by_type_[/decl/hierarchy/outfit/chaos/soldier], TRUE)

	return 1

/obj/effect/step_trigger/chaos_recruit
	var/used = 0

/obj/effect/step_trigger/chaos_recruit/Trigger(atom/movable/A)
	if(used || !ishuman(A))
		return
	var/mob/living/carbon/human/H = A
	if(!H.mind || H.mind.assigned_role != "Класс D")
		return
	if(H.ckey in chaos_recruited)
		return
	if(H.mind.special_role == "Chaos Insurgent")
		return

	var/choice = alert(H, "Are you sure you want to escape the facility and join the Chaos Insurgency?", "Join Chaos", "Yes", "No")
	if(choice != "Yes")
		return

	used = 1
	chaos_recruited += H.ckey

	recruit_chaos(H)

	if(!chaos_triggered)
		chaos_triggered = 1
		trigger_chaos_team()

/proc/recruit_chaos(mob/living/carbon/human/H)
	var/turf/T = get_turf(H)
	for(var/obj/item/I in list(H.w_uniform, H.wear_suit, H.head, H.glasses,
	                         H.gloves, H.shoes, H.belt, H.back, H.wear_mask))
		if(I)
			H.drop_from_inventory(I)
			if(T)
				I.forceMove(T)

	var/datum/antagonist/chaos/team = GLOB.chaos
	if(team)
		team.add_antagonist(H.mind)

	to_chat(H, "<span class='danger'>YOU HAVE BECOME A CHAOS INSURGENT!</span>")
	to_chat(H, "<span class='warning'>[GLOB.chaos.antag_text]</span>")
