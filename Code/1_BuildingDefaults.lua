local buildingGameInit = ShiftsBuilding.GameInit
function ShiftsBuilding:GameInit(...)
  print("ShiftsBuilding:GameInit()")
  buildingGameInit(self, ...)
  Msg("BuildingDefaultsGameInit", self)
end

BuildingDefaults.ModFuncs.domeBuildingOpenShifts = function(building)
  building:OpenShift(1)
  building:OpenShift(2)
  building:OpenShift(3)
  print("Opened all shifts for ", building.entity)
end

BuildingDefaults.ModFuncs.outdoorBuildingOpenShifts = function(building)
  print("Outdoor building that has shifts: ", building.entity, building.class)
  print("Building max workers: ", building.max_workers or "0")
  building:OpenShift(1)
  building:OpenShift(2)
  if building.max_workers == nil or building.max_workers <= 0 then
    building:OpenShift(3)
  else
    if UICity.tech_status["MartianbornResilience"].researched ~= nil then
      building:OpenShift(3)
    else
      building:CloseShift(3)
    end
  end
end

local function onMartianbornResilienceLearned(tech_id, city)
  for i = 1, #(city.labels.OutsideBuildings or "") do
    local building = city.labels.OutsideBuildings[i]
    BuildingDefaults.ModFuncs.outdoorBuildingOpenShifts(building)
  end
end

function OnMsg.TechResearched(tech_id, city)
  if tech_id == "MartianbornResilience" then
    onMartianbornResilienceLearned(tech_id, city)
  end
end

BuildingDefaults.ModFuncs.isFarm = function(building)
  return building.entity == "Farm" or building.entity == "HydroponicFarm" or building.entity == "FungalFarm"
end

function OnMsg.BuildingDefaultsGameInit(building)
  print("Received message BuildingDefaultsGameInit")
  if BuildingDefaults.ModFuncs.isFarm(building) then
    print("Building is a farm:", building.entity)
    return
  elseif not IsObjInDome(building) then
    print("Building is an outside building:", building.entity)
    BuildingDefaults.ModFuncs.outdoorBuildingOpenShifts(building)
  else
    print("Building is a dome building:", building.entity)
    BuildingDefaults.ModFuncs.domeBuildingOpenShifts(building)
  end
end
