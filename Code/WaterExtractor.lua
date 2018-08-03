local function updateWaterExtractor(extractor, total_extra_required)
    local new_extra_requirement = total_extra_required
    local current_working = extractor.ui_working

    if new_extra_requirement > 0
        or IsOnScreenNotificationShown("DustStorm")
        or g_DustStorm
        or g_ColdWave
    then
        if not current_working then
            print("turning on water extractor")
            extractor:SetUIWorking(true)
        end
        new_extra_requirement = new_extra_requirement - extractor.water_production
    else
        if current_working then
            print("turning off water extractor")
            extractor:SetUIWorking(false)
        end
    end
    extractor:UpdateWorking()
    return new_extra_requirement
end

local origGameInit = WaterExtractor.GameInit
function WaterExtractor:GameInit(...)
    origGameInit(self, ...)
    updateWaterExtractor(self)
end

local function updateWaterExtractorsWorking()
    local UICity = UICity
    local num_water_extractors = #(UICity and UICity.labels.WaterExtractor or empty_table)
    if (num_water_extractors == 0) then
        return
    end

    local num_moisture_vaporators = #(UICity and UICity.labels.MoistureVaporator or empty_table)
    local vaporator_production = 0
    for i=1, num_moisture_vaporators do
        local vaporator = UICity.labels.MoistureVaporator[i]
        vaporator_production = vaporator_production + vaporator.water_production
    end

    local total_extra_required = ResourceOverviewObj.data.total_water_demand - vaporator_production

    for i = 1, num_water_extractors do
        local extractor = UICity.labels.WaterExtractor[i]
        total_extra_required = updateWaterExtractor(extractor, total_extra_required)
    end
end

function OnMsg.DustStorm()
    updateWaterExtractorsWorking()
end

function OnMsg.TriggerDustStorm()
    updateWaterExtractorsWorking()
end

function OnMsg.DustStormEnded()
    updateWaterExtractorsWorking()
end

function OnMsg.NewHour()
    updateWaterExtractorsWorking()
end

function OnMsg.DMBDUpdatedSubsurfaceHeaterState()
    updateWaterExtractorsWorking()
end
