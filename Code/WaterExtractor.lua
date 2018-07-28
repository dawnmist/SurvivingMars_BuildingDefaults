local function updateWaterExtractor(extractor, production)
    local newProduction = production
    local consumption = (extractor.water.grid.current_consumption or 0)
    local stopped_production = production - (extractor.water_production or 0)
    local current_working = extractor.ui_working
    --print("Updated production if stopped:", stopped_production, ", current_working:", current_working)
    if consumption > stopped_production then
        if not current_working then
            print("Not producing enough water: turn on extractor")
            extractor:SetUIWorking(true)
        end
    elseif g_DustStorm then
        if not current_working then
            print("Duststorm - turning on water extractors")
            extractor:SetUIWorking(true)
        end
    elseif IsOnScreenNotificationShown("DustStorm") then
        if not current_working then
            print("Duststorm Notification - turning on water extractors")
            extractor:SetUIWorking(true)
        end
    else
        if current_working then
            print("No duststorm - turning off water extractors")
            newProduction = production - extractor.water_production
            extractor:SetUIWorking(false)
        end
    end
    extractor:UpdateWorking()
    return newProduction
end

local origGameInit = WaterExtractor.GameInit
function WaterExtractor:GameInit(...)
    origGameInit(self, ...)
    updateWaterExtractor(self)
end

local function updateWaterExtractorsWorking()
    local numWaterProducers = #(UICity and UICity.labels.WaterExtractor or empty_table)
    if (numWaterProducers == 0) then
        return
    end

    local extraPossibleProduction = 0
    for i = 1, numWaterProducers do
        local extractor = UICity.labels.WaterExtractor[i]
        if not extractor.ui_working then
            extraPossibleProduction = extractor.water_production
        end
    end
    local firstExtractor = UICity.labels.WaterExtractor[1]
    local production = ResourceOverviewObj.data.total_water_production
    local consumption = ResourceOverviewObj.data.total_water_consumption
    local throttled = firstExtractor.water.grid.current_throttled_production
    local storage = firstExtractor.water.grid.current_storage_change
    local totalProduction = production + throttled + extraPossibleProduction

    --[[print(
        "Current Production:",
        production,
        ", Throttled:",
        throttled,
        ", Extra:",
        extraPossibleProduction,
        ", Total possible production:",
        totalProduction,
        ", Current consumption:",
        consumption
    )]]
    production = totalProduction
    for i = 1, numWaterProducers do
        local extractor = UICity.labels.WaterExtractor[i]
        local updated_production = updateWaterExtractor(extractor, production)
        production = updated_production
    end
end

function OnMsg.DustStorm()
    print("OnMsg.DustStorm()")
    updateWaterExtractorsWorking()
end

function OnMsg.TriggerDustStorm()
    print("OnMsg.TriggerDustStorm()")
    updateWaterExtractorsWorking()
end

function OnMsg.DustStormEnded()
    print("OnMsg.DustStormEnded()")
    updateWaterExtractorsWorking()
end

function OnMsg.NewHour()
    updateWaterExtractorsWorking()
end

function OnMsg.DMBDUpdatedSubsurfaceHeaterState()
    print("OnMsg.DMBDUpdatedSubsurfaceHeaterState()")
    updateWaterExtractorsWorking()
end
