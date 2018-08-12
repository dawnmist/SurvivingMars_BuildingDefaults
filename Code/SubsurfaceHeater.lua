local heaterChanges = false

local function hasColdEnvironment(building)
    local range = building:GetHeatRange()
    local border = building:GetHeatBorder()
    local hasFrozenGround = false

    ForEach{
        class = "ColdSensitive",
        area = building,
        arearadius = range + border/2,
        exec = function(obj)
            local temperature = GetHeatAt(obj)
            local tooCold = obj.penalty_heat
            if (obj.freeze_heat > tooCold) then
                tooCold = obj.freeze_heat
            end
            hasFrozenGround = temperature <= tooCold
            if (hasFrozenGround) then
                return "break"
            end
        end
    }

    return hasFrozenGround
end

local function updateSubsurfaceHeater(building)
    building:SetPriority(3)
    local currentWorkingState = building.ui_working
    if hasColdEnvironment(building) then
        if not currentWorkingState then
            building:SetUIWorking(true)
            heaterChanges = true
        end
    elseif g_ColdWave then
        if not currentWorkingState then
            building:SetUIWorking(true)
            heaterChanges = true
        end
    elseif IsOnScreenNotificationShown("ColdWave") then
        if not currentWorkingState then
            -- notified that a ColdWave is approaching, turn on so they can be repaired
            building:SetUIWorking(true)
            heaterChanges = true
        end
    else
        if currentWorkingState then
            -- not needed so turn off
            building:SetUIWorking(false)
            heaterChanges = true
        end
    end
    building:UpdateWorking()
end

local origGameInit = SubsurfaceHeater.GameInit
function SubsurfaceHeater:GameInit(...)
    print("SubsurfaceHeater:GameInit()")
    origGameInit(self, ...)
    updateSubsurfaceHeater(self)
end

local function updateSubsurfaceHeatersWorking()
    heaterChanges = false
    for key,building in pairs(UICity and UICity.labels.SubsurfaceHeater or empty_table) do
        updateSubsurfaceHeater(building)
    end
    if heaterChanges then
        CreateGameTimeThread(
            function()
                -- make sure that the game has time to update water demand
                WaitMsg("NewMinute")
                -- notifiy other items of change of subsurface heaters state
                Msg("DMBDUpdatedSubsurfaceHeaterState")
            end
        )
    end
end

function OnMsg.ColdWave()
    updateSubsurfaceHeatersWorking()
end

function OnMsg.ColdWaveEnded()
    updateSubsurfaceHeatersWorking()
end

function OnMsg.NewHour()
    updateSubsurfaceHeatersWorking()
end
