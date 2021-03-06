local function updateMetalsExtractor(extractor)
    local UICity = UICity
    extractor:SetUIWorking(true)
    extractor:OpenShift(1)
    extractor:OpenShift(2)

    if UICity.tech_status["ExtractorAI"].researched ~= nil
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
