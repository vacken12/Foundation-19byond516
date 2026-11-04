#if !defined(using_map_DATUM)

	#include "siteCB_announcements.dm"
	#include "siteCBareas.dm"
	#include "siteCBelevators.dm"
	#include "siteCB_presets.dm"
	#include "siteCB_landmarks.dm"
	#include "siteCBshuttles.dm"
	#include "siteCB_define.dm"

	#include "items/encryption_keys.dm"
	#include "items/headsets.dm"
	#include "items/items.dm"
	#include "items/manuals.dm"
	#include "items/stamps.dm"
	#include "items/rigs.dm"
	#include "items/clothing/solgov-accessory.dm"
	#include "items/clothing/solgov-armor.dm"
	#include "items/clothing/solgov-feet.dm"
	#include "items/clothing/solgov-head.dm"
	#include "items/clothing/solgov-suit.dm"
	#include "items/clothing/solgov-under.dm"

	#include "job/headsets.dm"
	#include "job/papers.dm"
	#include "job/access/access.dm"
	#include "job/access/access_containment.dm"
	#include "structures/mapstuff.dm"
	#include "structures/signs.dm"
	#include "structures/closets/command.dm"
	#include "structures/closets/medical.dm"
	#include "structures/closets/misc.dm"
	#include "structures/closets/research.dm"
	#include "structures/closets/security.dm"
	#include "structures/closets/services.dm"
	#include "structures/closets/supply.dm"

	#include "siteCB.dmm"
	#include "z1_admin.dmm"
	#include "z2_transit.dmm"

	#define using_map_DATUM /datum/map/siteCB

#elif !defined(MAP_OVERRIDE)

	#warn A map has already been included, ignoring Site CB

#endif
