function OnMsg.BuildingDefaultsGameInit(building)
    if building.entity == "ShopsFood" or building.entity == "Restaurant" then
        building:SetPriority(3)
    end
end
