-- Add a message to the Martian Thermostat Enable/Disable functions.
function OnMsg.Autostart()
    local originalStart = MTEnableHeaters
    local originalEnd = MTDisableHeaters

    function MTEnableHeaters(...)
        originalStart(self, ...)
        CreateGameTimeThread(
            function()
                -- make sure that the game has time to update water demand
                WaitMsg("NewMinute")
                -- notifiy other items of change of subsurface heaters state
                Msg("DMBDUpdatedSubsurfaceHeaterState")
            end
        )
    end

    function MTDisableHeaters(...)
        originalEnd(self, ...)
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