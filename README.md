# Building Defaults mod for Surviving Mars

This mod is something that I put together and continue to tweak to suit my own gameplay - as such, it may not suit you perfectly in its current form. Its purpose is to set up and maintain the basic logic behind building work choices - things like what shifts to run by default, when to turn on/off buildings, what crops to grow, what traits to teach, etc.

My original reason for starting this was I was getting frustrated with not being able to set up the default working state for a building as it got built. Things like school traits could be copied to all existing buildings - but new buildings would start with the original set rather than the set you'd copied over. If I was working on several areas of the colony at the same time, it was very common that I'd forget to go back and set up some of the new buildings once construction completed, and they'd run for several Sols with the wrong settings before I'd notice the issue. Or I'd do something like turn off the solar cells for a Dust Storm, then forget to turn them back on at the end. I wanted to be able to set the default behaviours for the various buildings so that when new buildings were constructed they did something sensible.

I've uploaded it more so that if there is anything that I have done that would be useful for someone else (including stuff like calculations, etc), my code can be used as a reference.

Please note: Currently this is set around the Curiosity patch version of Surviving Mars. While DaVinci was released a few days ago, I am experiencing a crash bug at the Main Menu that makes it unable to be played (fresh game, fresh userdata directory, no mods). A few of the items in this mod will likely be unnecessary or need adjustment once a patch is released that lets me play the DaVinci version.

## Code Files

### Code/1_BuildingDefaults.lua - Overall defaults for all buildings with shifts

I generally play with indoor buildings set to work all 3 shifts, and outdoor ones set to work 2 shifts. Later in the game when I have mostly Martianborn colonists and have learned the Martianborn Resilience trait I open up the outdoor night shifts too. Outdoor buildings with shifts but that don't need to have colonists also open all 3 shifts. The 1_BuildingDefaults.lua configures the basic shifts for new buildings, and updates the outdoor buildings when the Martianborn Resilience trait is learned.

### Code/Farms.lua - Defaults for Farms, Hydroponic Farms and Fungal Farms

This file manages the crop rotations and shifts for farms. By default, every second farm/hydroponic farm/fungal farm is assigned as afternoon shift so that energy use and colonist free time is spread out across the day. Each farm type is treated separately - i.e. building a fungal farm does not affect the shifts for a normal farm or for a hydroponic farm. I kept them separate because the different types have significantly different resource requirements, which meant that if they used a combined counter they could still get wildly unbalanced.

#### Farms

Only one crop per farm is set at any one time - the next crop to grow gets set after the current crop completes at the point where the soil quality has been updated. The next crop chosen depends on a combination of:

* Soil Quality
* Technologies/Breakthroughs Researched
* Mystery (cure potatoes)

The general logic is:

* If the soil quality is less than 100%, aim to improve it.
* If the soil quality is less than 70% and cover crops is available, use those to improve quickly.
* If the soil quality is 100%, pick the best performing crop currently available (that won't take more than 4 days to complete).

#### Hydroponic Farms

Only 1 crop per hydroponic farm is set at a time, and this is updated when the current crop completes. The next crop chosed depends on a combination of:

* Presence of a Dust Storm (high oxygen yield crops)
* Technologies/Breakthroughs Researched
* Mystery (Ganymede Rice)

The general logic is to pick the highest performing crop available at the time:

* If in a Dust Storm, pick the crop with the highest oxygen output. If two crops with the same oxygen output pick the highest yield.
* If not in a Dust Storm, pick the highest yield crop available.

#### Fungal Farms

I haven't felt the need to tweak these beyond setting every second one to an afternoon shift, though I may in future decide to turn Superfungus on/off during Dust Storms.

### Code/FoodShops.lua

This file sets the priority of the Grocery and Diner to max so that drones are less likely to let them run out of food supplies entirely.

### Code/MartianUniversity.lua

This file bans middle-aged colonists or colonists with the Idiot trait from attending University.

### Code/MiningBuildings.lua

This file controls the working state of Metal and Rare Metal mines based on Cold Waves or Technologies researched.

The general logic is:

* If a cold wave is active, turn all 3 shifts on so the building doesn't freeze.
* If the Extractor AI technology is researched, close all work places but turn all shifts on so it uses the automation rather than colonists.
* If the Martianborn Resilience technology is researched, turn on the night shift.
* Else use only Morning and Afternoon shifts by default.

Future tweak planned: I'd like to update the "cold wave active" part so that if the mine is in range of a subsurface heater it doesn't need to turn on the night shift, but I haven't had a look at how to do that yet.

### Code/School.lua

This file sets up the traits that I'd like taught at schools, based on technologies researched and current mystery.

Traits are taught in the order of:

1. Workaholic (if Interplanetary Learning has been researched)
2. Dreamer (if the Dream Mystery is active/completed after Dream Simulation has been researched)
3. Enthusiast
4. Composed
5. Religious

### Code/SubsurfaceHeater.lua

This is used to turn the Subsurface Heaters on/off.

* If there is an active Cold Wave, turn the heater on.
* If there is an active notification that a Cold Wave is coming, turn the heater on.
* If there are buildings within range of the heater that are on frozen ground, turn the heater on.
* Otherwise turn it off.

Any time the mod updates the working state of a subsurface heater due to Cold Wave conditions the message "DMBDUpdatedSubsurfaceHeaterState" is emitted so that other buildings (in particular, water extractors) can also be updated.

### Code/WaterExtractor.lua

This is used to turn Water Extractors on/off.

* If there is an active Dust Storm (water vaporators not working) or Cold Storm (freezing), turn the water extractor on.
* If there is a greater need for water than can be supplied by the existing water vaporators, turn on just enough extractors to meet the need.
* Otherwise, turn the water extractors off.

When checking for a need for additional water, the mod uses the _possible_ output for each vaporator rather than its exact current output (e.g. if the vaporator has broken down needing maintenance, its normal output is still counted). After testing, I decided that minor breakdowns are the time you should be able to use stored water as a buffer rather than draw on the finite resources of the water deposit.

The output for a vaporator takes into account the increases in output from the two Vaporator upgrades if they have been installed on that vaporator.

Future tweak planned: I'd like to update the "cold wave active" part so that if the water extractor is in range of a subsurface heater it doesn't need to turn on during the cold wave, but I haven't had a look at how to do that yet.
