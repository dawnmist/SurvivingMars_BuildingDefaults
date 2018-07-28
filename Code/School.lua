local function setupSchool(school)
    local trait1 = "Enthusiast"
    local trait2 = "Composed"
    local trait3 = "Religious"
    if UICity.tech_status["InterplanetaryLearning"] and UICity.tech_status["InterplanetaryLearning"].researched ~= nil then
        trait2 = "Workaholic"
        trait3 = "Composed"
    end
    if UICity.tech_status["DreamSimulation"] and UICity.tech_status["DreamSimulation"].researched ~= nil then
        trait3 = "Dreamer"
    end

    school:SetTrait(1, trait1, false)
    school:SetTrait(2, trait2, false)
    school:SetTrait(3, trait3, false)
end

local function onSchoolRelatedTechLearned(tech_id)
    local UICity = UICity
    for i = 1, #(UICity.labels.School or empty_table) do
        local building = UICity.labels.School[i]
        setupSchool(building)
    end
end

function OnMsg.BuildingDefaultsGameInit(building)
    if building.entity == "School" then
        setupSchool(building)
    end
end

function OnMsg.TechResearched(tech_id)
    if tech_id == "InterplanetaryLearning" or tech_id == "DreamSimulation" then
        onSchoolRelatedTechLearned(tech_id)
    end
end
