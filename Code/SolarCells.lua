local function updateSolarPanelWorking(solarpanel)
    if g_DustStorm and not IsObjInDome(solarpanel) then
        solarpanel:SetUIWorking(false)
    else
        solarpanel:SetUIWorking(true)
    end
end

local function updateSolarPanels()
    local solarpanels = UICity.labels.SolarPanel
    for key,solarpanel in pairs(solarpanels) do
        updateSolarPanelWorking(solarpanel)
    end
end

function OnMsg.DustStorm()
    updateSolarPanels()
end

function OnMsg.DustStormEnded()
    updateSolarPanels()
end

function OnMsg.LoadGame()
    updateSolarPanels()
end