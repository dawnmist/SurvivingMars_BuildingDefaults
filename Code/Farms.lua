local noop = function () end

GlobalVar("DM_BD_FarmLastShift", 0)
GlobalVar("DM_BD_HydroponicLastShift", 0)
GlobalVar("DM_BD_FungalLastShift", 0)

local function setupFarmShifts(farm, lastShift)
    local nextShift = (lastShift == 1 and 2) or 1
    farm:OpenShift(nextShift)
    return nextShift
end

local function setupFarmConventional(farm)
    local crop1
    local soilQuality = farm.soil_quality / const.SoilQualityScale
    if soilQuality < 70 then
        if IsCropAvailable("Cover Crops") then
            crop1 = "Cover Crops"
        else
            crop1 = "Soybeans"
        end
    elseif IsCropAvailable("Cure") and soilQuality > 70 then
        crop1 = "Cure"
    else
        crop1 = "Soybeans"
    end
    farm:SetCrop(1, crop1, false)
    farm:SetCrop(2, nil, false)
    farm:SetCrop(3, nil, false)
end

local function steadyStateFarmConventional(farm)
    local quality = farm.soil_quality / const.SoilQualityScale
    if quality > 90 then
        local crop1
        if IsCropAvailable("Cure") then
            crop1 = "Cure"
        elseif IsCropAvailable("Giant Corn") then
            crop1 = "Giant Corn"
        elseif IsCropAvailable("Quinoa") then
            crop1 = "Quinoa"
        elseif IsCropAvailable("Giant Potatoes") then
            crop1 = "Giant Potatoes"
        else
            crop1 = "Potatoes"
        end
        farm:SetCrop(1, crop1, false)
        farm:SetCrop(2, nil, false)
        farm:SetCrop(3, nil, false)
    else
        setupFarmConventional(farm)
    end
end

local function steadyStateFarmHydroponic(farm)
    if g_DustStorm then
        if IsCropAvailable("Algae") then
            -- O2 = 1, 4/4
            farm:SetCrop(1, "Algae", false)
            return
        elseif IsCropAvailable("Mystery9_GanymedeRice") then
            -- O2 = 0.6, 12/4
            farm:SetCrop(1, "Mystery9_GanymedeRice", false)
            return
        elseif IsCropAvailable("Kelp") then
            -- O2 = 0.5, 12.8/4
            farm:SetCrop(1, "Kelp", false)
            return
        end
    end
    if IsCropAvailable("Giant Rice") then
        -- O2 = 0.1, prod = 20/4
        farm:SetCrop(1, "Giant Rice", false)
    elseif IsCropAvailable("Giant Leaf Crops") then
        -- O2 = 0.1, prod = 16/4
        farm:SetCrop(1, "Giant Leaf Crops", false)
    elseif IsCropAvailable("Rice") then
        -- O2 = 0.1, prod = 15/4
        farm:SetCrop(1, "Rice", false)
    elseif IsCropAvailable("Giant Wheat Grass") then
        -- O2 = 0.1, prod = 14/4
        farm:SetCrop(1, "Giant Wheat Grass", false)
    elseif IsCropAvailable("Vegetables") then
        -- O2 = 0.1, prod = 12.5/4
        farm:SetCrop(1, "Vegetables", false)
    elseif IsCropAvailable("Mystery9_GanymedeRice") then
        -- O2 = 0.6, prod = 12/4
        farm:SetCrop(1, "Mystery9_GanymedeRice", false)
    else
        -- O2 = 0.1, prod = 12/4
        farm:SetCrop(1, "Leaf Crops", false)
    end
end

local function steadyStateFarmFungal(farm)
end

local function setupFarmHydroponic(farm)
    steadyStateFarmHydroponic(farm)
end

local function setupFarmFungal(farm)
    steadyStateFarmFungal(farm)
end

local origFarmInit = Farm.GameInit
function Farm:GameInit(...)
    origFarmInit(self, ...)
    if self.hydroponic then
        DM_BD_HydroponicLastShift = setupFarmShifts(self, DM_BD_HydroponicLastShift)
        setupFarmHydroponic(self)
    else
        DM_BD_FarmLastShift = setupFarmShifts(self, DM_BD_FarmLastShift)
        setupFarmConventional(self)
    end
end

local origFungalFarmInit = FungalFarm.GameInit
function FungalFarm:GameInit(...)
    origFungalFarmInit(self, ...)
    DM_BD_FungalLastShift = setupFarmShifts(self, DM_BD_FungalLastShift)
    setupFarmFungal(self)
end

-- Soil quality isn't updated yet when OnMsg.FoodProduced is fired.
local origFarmSoilQuality = Farm.SetSoilQuality
function Farm:SetSoilQuality(...)
    origFarmSoilQuality(self, ...)
    if not self.hydroponic then
        steadyStateFarmConventional(self)
    end
end

-- Update crop lists for steady-state production
function OnMsg.FoodProduced(farm, amount_produced)
    if farm.hydroponic then
        steadyStateFarmHydroponic(farm)
    elseif farm.entity == "Farm" then
        -- wait until soil quality has been updated
    else
        steadyStateFarmFungal(farm)
    end
end
