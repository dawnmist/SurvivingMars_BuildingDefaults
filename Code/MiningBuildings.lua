local function updateMetalsExtractor(extractor)
    local UICity = UICity
    extractor:SetUIWorking(true)
    extractor:OpenShift(1)
    extractor:OpenShift(2)

    if UICity.tech_status["ExtractorAI"].researched ~= nil
       or IsOnScreenNotificationShown("ColdWave")
       or g_ColdWave
       or UICity.tech_status["MartianbornResilience"].researched ~= nil
    then
        extractor:OpenShift(3)
        if UICity.tech_status["ExtractorAI"].researched ~= nil then
            -- Set workers per shift to 0
            extractor:CloseAllWorkplacesWithoutClosingShift(1)
            extractor:CloseAllWorkplacesWithoutClosingShift(2)
            extractor:CloseAllWorkplacesWithoutClosingShift(3)
        end
    else
        extractor:CloseShift(3)
    end
end

local origGameInit = BaseMetalsExtractor.GameInit
function BaseMetalsExtractor:GameInit(...)
    if origGameInit ~= nil then
        origGameInit(self, ...)
    end
    updateMetalsExtractor(self)
end

local function updateExtractors()
    local extractors = UICity.labels.BaseMetalsExtractor or empty_table
    for key,extractor in pairs(extractors) do
        updateMetalsExtractor(extractor)
    end
end

function OnMsg.TechResearched(tech_id, city)
    if tech_id == "ExtractorAI" or "MartianbornResilience" then
        updateExtractors()
	end
end

function OnMsg.ColdWave()
    local data = DataInstances.MapSettings_ColdWave
    local cold_wave = data[mapdata.MapSettings_ColdWave] or data["ColdWave_VeryLow"]
    if cold_wave then
        CreateGameTimeThread(function()
            local notification_time = GameTime()
            local warn_time = GetDisasterWarningTime(cold_wave)
            local sleep_time = warn_time - (2 * const.HourDuration)
            -- want to trigger no earlier than 2 hours prior to cold wave triggering
            if sleep_time > 0 then
                Sleep(sleep_time)
            end
            updateExtractors()
        end)
    end
end

function OnMsg.ColdWaveEnded()
    updateExtractors()
end