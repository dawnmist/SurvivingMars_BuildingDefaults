local buildingGameInit = ShiftsBuilding.GameInit
function ShiftsBuilding:GameInit(...)
  buildingGameInit(self, ...)
  Msg("BuildingDefaultsGameInit", self)
end

local function domeBuildingOpenShifts(building)
  building:OpenShift(1)
  building:OpenShift(2)
  building:OpenShift(3)
end

local function outdoorBuildingOpenShifts(building)
  building:OpenShift(1)
  building:OpenShift(2)
  if building.max_workers == nil or building.max_workers <= 0 then
    building:OpenShift(3)
  elseif UICity.tech_status["MartianbornResilience"].researched ~= nil then
    building:OpenShift(3)
  else
    building:CloseShift(3)
  end
end

local function onMartianbornResilienceLearned(tech_id, city)
  for key,building in pairs(city.labels.OutsideBuildings or empty_table) do
    outdoorBuildingOpenShifts(building)
  end
end

function OnMsg.TechResearched(tech_id, city)
  if tech_id == "MartianbornResilience" then
    onMartianbornResilienceLearned(tech_id, city)
  end
end

local function isFarm(building)
  return building.entity == "Farm" or building.entity == "HydroponicFarm" or building.entity == "FungalFarm"
end

function OnMsg.BuildingDefaultsGameInit(building)
  if isFarm(building) then
    return
  elseif not IsObjInDome(building) then
    outdoorBuildingOpenShifts(building)
  else
    domeBuildingOpenShifts(building)
  end
end
