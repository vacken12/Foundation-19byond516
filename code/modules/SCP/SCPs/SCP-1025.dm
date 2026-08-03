// SCP-1025: The Encyclopedia of Diseases
// A book that infects the reader with a random disease when read.

/obj/item/book/scp1025
	name = "encyclopedia of diseases"
	icon = 'icons/SCP/scp-1025.dmi'
	icon_state = "scp1025"
	desc = "A large encyclopedia that contains detailed information about various diseases."
	title = "encyclopedia of diseases"
	unique = TRUE // Cannot be modified with a pen or copied

	/// Disease types that can be contracted from reading the book.
	var/static/list/possible_diseases = list(
		/datum/disease/cold,
		/datum/disease/rage,
		/datum/disease/advance/flu,
		/datum/disease/advance/paranoia,
		/datum/disease/scp306,
		/datum/disease/scp610,
		/datum/disease/advance/scp714,
	)

/obj/item/book/scp1025/attack_self(mob/living/user)
	if(!isliving(user))
		return

	user.visible_message(SPAN_NOTICE("\The [user] begins reading \the [src]."))

	if(!do_after(user, 5 SECONDS, user))
		return

	var/disease_type = pick(possible_diseases)
	var/datum/disease/D = new disease_type()
	var/disease_name = D.name

	// make_copy=FALSE: use the instance directly (no orphaned copy)
	// del_on_fail=TRUE: clean up the datum if infection is blocked
	if(!user.ForceContractDisease(D, make_copy = FALSE, del_on_fail = TRUE))
		to_chat(user, SPAN_NOTICE("You read through the encyclopedia, but feel fine."))
		return

	to_chat(user, SPAN_NOTICE("You read something about [disease_name] from the encyclopedia. A wave of illness washes over you..."))

	user.setClickCooldown(CLICK_CD_QUICK)
