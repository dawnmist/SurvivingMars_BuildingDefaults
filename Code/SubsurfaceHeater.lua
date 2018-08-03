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
            print("Covers cold environment - turn SubsurfaceHeater on")
            building:SetUIWorking(true)
            heaterChanges = true
        end
    elseif g_ColdWave then
        if not currentWorkingState then
            print("ColdWave - turn SubsurfaceHeater on")
            building:SetUIWorking(true)
            heaterChanges = true
        end
    elseif IsOnScreenNotificationShown("ColdWave") then
        if not currentWorkingState then
            -- notified that a ColdWave is approaching, turn on so they can be repaired
            print("ColdWave Notification - turn SubsurfaceHeater on")
            building:SetUIWorking(true)
            heaterChanges = true
        end
    else
        if currentWorkingState then
            -- not needed so turn off..."Don't be a Wally with Water"
            print("No ColdWave - turn SubsurfaceHeater off")
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
    for i = 1, #(UICity and UICity.labels.SubsurfaceHeater or "") do
        local building = UICity.labels.SubsurfaceHeater[i]
        updateSubsurfaceHeater(building)
    end
    if heaterChanges then
        CreateGameTimeThread(
            function()
                WaitMsg("NewMinute")
                Msg("DMBDUpdatedSubsurfaceHeaterState")
            end
        )
    end
end

function OnMsg.ColdWave()
    print("OnMsg.ColdWave() received")
    updateSubsurfaceHeatersWorking()
end

function OnMsg.TriggerColdWave()
    print("OnMsg.TriggerColdWave()")
    updateSubsurfaceHeatersWorking()
end

function OnMsg.ColdWaveEnded()
    print("OnMsg.ColdWaveEnded()")
    updateSubsurfaceHeatersWorking()
end

function OnMsg.NewHour()
    updateSubsurfaceHeatersWorking()
end
