/decl/hierarchy/outfit/scp527
	name = "SCP-527"
	head = /obj/item/clothing/head/scp527
	uniform = /obj/item/clothing/under/scp/hdclass
	shoes = /obj/item/clothing/shoes/dress
	l_pocket = /obj/item/card/id/dassignment/dluxury
	flags = OUTFIT_HAS_BACKPACK | OUTFIT_RESET_EQUIPMENT

/obj/item/clothing/head/scp527
	name = "Mr.Fish's top hat"
	desc = "A stylish top hat that completes your look. It's permanently attached to your head."
	icon = 'icons/obj/clothing/obj_head.dmi'
	icon_state = "tophat"
	item_state = "dermal"
	canremove = FALSE

/obj/item/clothing/head/scp527/dropped(mob/user)
	. = ..()
	qdel(src)

/decl/hierarchy/outfit/scp347
	name = "SCP-347"
	uniform = /obj/item/clothing/under/scp/hdclass
	shoes = /obj/item/clothing/shoes/orange
	gloves = /obj/item/clothing/gloves/color
	l_pocket = /obj/item/card/id/dassignment/dluxury
	flags = OUTFIT_HAS_BACKPACK | OUTFIT_RESET_EQUIPMENT

/decl/hierarchy/outfit/scp2020
	name = "SCP-2020"
	uniform = /obj/item/clothing/under/scp/hdclass
	shoes = /obj/item/clothing/shoes/orange
	l_pocket = /obj/item/card/id/dassignment/dluxury
	flags = OUTFIT_HAS_BACKPACK | OUTFIT_RESET_EQUIPMENT

/decl/hierarchy/outfit/scp912
	name = "SCP-912"
	gloves = /obj/item/clothing/gloves/thick/swat
	uniform = /obj/item/clothing/under/scp/scp912
	suit = /obj/item/clothing/suit/storage/vest/scp912
	belt = /obj/item/storage/belt/holster/security/tactical/full912pistol
	head = /obj/item/clothing/head/helmet/scp912
	mask = /obj/item/clothing/mask/balaclava
	shoes = /obj/item/clothing/shoes/swat
	l_pocket = /obj/item/melee/telebaton
	r_pocket = /obj/item/material/knife/combat
	back = /obj/item/storage/backpack/satchel/pocketbook
	backpack_contents = /obj/item/gun/energy/taser
	flags = OUTFIT_RESET_EQUIPMENT

