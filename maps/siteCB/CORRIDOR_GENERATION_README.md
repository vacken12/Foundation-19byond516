# Site CB Corridor Generation System

## Overview
This system generates random corridors each game round for the Site CB map. The generation starts from the landmark `/obj/effect/landmark/siteCB/start` and creates a random layout using predefined corridor presets.

## Files Created/Modified

### New Files
1. `maps/siteCB/corridor_generation.dm` - Main corridor generation logic
2. `maps/siteCB/CORRIDOR_GENERATION_README.md` - This documentation

### Modified Files
1. `maps/siteCB/site53_define.dm` - Added corridor generation initialization
2. `maps/siteCB/site53.dm` - Added #include for site53_define.dm

## How It Works

### 1. Start Landmark
The system begins at `/obj/effect/landmark/siteCB/start`. This landmark should be placed in your base map file (site53.dmm) where you want corridor generation to begin.

### 2. Corridor Presets
Four corridor templates are used from `maps/siteCB/map_templates/`:
- **corHori.dmm** - Horizontal corridor (9x5)
- **corHoriR.dmm** - Horizontal corridor with room (7x5)
- **corVert.dmm** - Vertical corridor (5x7)
- **corL.dmm** - L-shaped corridor (7x7)

Each preset has exit landmarks:
- `/obj/effect/landmark/siteCB/exit1`
- `/obj/effect/landmark/siteCB/exit2`
- `/obj/effect/landmark/siteCB/exit3`
- `/obj/effect/landmark/siteCB/room` (for room connections)

### 3. Generation Process
1. Locates the start landmark
2. Randomly selects 5-12 corridors to place
3. For each corridor:
   - Randomly picks a template type
   - Randomly chooses orientation (horizontal vs vertical)
   - Attempts to place it near the current position
   - Checks for overlaps with previously placed corridors
   - Loads the template at the calculated position
   - Updates the current position to one of the corridor's exits
4. Logs the generation process to the world log

### 4. Randomization
Each round:
- Number of corridors varies (5-12)
- Types are randomly selected
- Orientations are randomly chosen
- Positions are offset randomly from the current location
- Exit selection is random

## Integration

The system is integrated into the map's `setup_map()` proc:

```dm
/datum/map/site53/setup_map()
	..()
	// Generate corridors after map setup
	generate_corridors()
```

This override is called automatically during map initialization (see `maps/~mapsystem/maps.dm` line 14).

## Configuration

You can adjust these parameters in `maps/siteCB/corridor_generation.dm`:

- **Corridor Count**: Change `rand(5, 12)` to adjust min/max corridors
- **Position Offset**: Modify `rand(-3, 3)` for more/less branching
- **Overlap Attempts**: Change the `10` in the retry loop
- **World Bounds**: Adjust the `5` and `world.maxx/maxy` values for margins

## Testing

1. Start the server with Site CB map selected
2. Check the world log for messages like:
   - "Corridor Generation: Starting at X,Y,Z"
   - "Corridor Generation: Placed [name] at X,Y,Z"
   - "Corridor Generation: Completed! Placed N total turfs"

3. Verify corridors spawn randomly each round
4. Verify no major overlaps occur (some minor intersections are okay)

## Troubleshooting

### Corridors not spawning?
- Check that start landmark exists in your map
- Verify `site53_define.dm` is included in `site53.dm`
- Check world log for errors

### Overlapping corridors?
- The system has overlap detection but may occasionally place intersecting corridors
- Adjust the `rand(-3, 3)` offset to reduce proximity
- Increase the retry attempts (currently 10)

### Corridors out of bounds?
- Check world.maxx and world.maxy in your map configuration
- Adjust the margin values (currently 5 tiles from edges)
