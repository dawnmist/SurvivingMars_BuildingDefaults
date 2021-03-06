local function updateWaterExtractor(extractor, total_extra_required)
    local new_extra_requirement = total_extra_required
    local current_working = extractor.ui_working

    if new_extra_requirement > 0
        or IsOnScreenNotificationShown("DustStorm")
        or IsOnScreenNotificationShown("ColdWave")
        or g_DustStorm
        or g_ColdWave
    then
        if not current_working then
            extractor:SetUIWorking(true)
        end
        new_extra_requirement = new_extra_requirement - extractor.water_production
    elseif current_working then
        extractor:SetUIWorking(false)
    end
    extractor:UpdateWorking()
    return new_extra_requirement
end

local function calculateWaterProductionNeeded()
    local UICity = UICity
    local num_water_extractors = #(UICity and UICity.labels.WaterExtractor or empty_table)
    if (num_water_extractors == 0) then
        return 0
    end

    local num_moisture_vaporators = #(UICity and UICity.labels.MoistureVaporator or empty_table)
    local vaporator_production = 0
    for i = 1, #(UICity.labels.MoistureVaporator or empty_table) do
        -- vaporator.water.production = current production, vaporator.water_production = possible production
        local vaporator = UICity.labels.MoistureVaporator[i]
        vaporator_production = vaporator_production + vaporator.water_production
    end

    return ResourceOverviewObj.data.total_water_demand - vaporator_production
end

local function updateWaterExtractorsWorking()
    local UICity = UICity
    local total_extra_required = calculateWaterProductionNeeded()

    for i = 1, #(UICity.labels.WaterExtractor or empty_table) do
        local extractor = UICity.labels.WaterExtractor[i]
        total_extra_required = updateWaterExtractor(extractor, total_extra_required)
    end
end

local origGameInit = WaterExtractor.GameInit
function WaterExtractor:GameInit(...)
    origGameInit(self, ...)
    updateWaterExtractor(self, calculateWaterProductionNeeded())
end

function OnMsg.DustStorm()
    updateWaterExtractorsWorking()
end

function OnMsg.DustStormEnded()
    updateWaterExtractorsWorking()
end

-- Subsurface Heaters have just either turned on or turned off.
function OnMsg.DMBDUpdatedSubsurfaceHeaterState()
    updateWaterExtractorsWorking()
end

function OnMsg.ColdWave()
    updateWaterExtractorsWorking()
end

function OnMsg.ColdWaveEnded()
    updateWaterExtractorsWorking()
end
