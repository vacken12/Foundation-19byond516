
#include "site42_announcements.dm"
#include "site42areas.dm"
//#include "site42elevators.dm"
#include "site42_presets.dm"
//#include "site42shuttles.dm"

#include "site42.dmm"




#if !defined(using_map_DATUM)


	//#include "z42_admin.dmm"
	//#include "z42_transit.dmm"


	#define using_map_DATUM /datum/map/site42

#elif !defined(MAP_OVERRIDE)

	#warn A map has already been included, ignoring Site 42

#endif
