local LICENSE =
    [[Any code from https://github.com/HaemimontGames/SurvivingMars is copyright by their LICENSE

All of my code is licensed under the MIT License as follows:

MIT License

Copyright (c) [2018] [Dawnmist]

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.]]
-- Many thanks to ChoGGi and SkiRich for assistance with setting this mod up.

-- if we use global func more then once: make them local for that small bit o' speed
local select, tostring, type, pcall, table = select, tostring, type, pcall, table
local AsyncFileOpen = AsyncFileOpen

-- just in case they remove oldTableConcat
local TableConcat
pcall(
    function()
        TableConcat = oldTableConcat
    end
)
TableConcat = TableConcat or table.concat

-- Mod defaults
BuildingDefaults = {
    _LICENSE = LICENSE,
    id = "Dawnmist_BuildingDefaults",
    email = "gh@dawnmist.net",
    -- replaced functions
    OrigFuncs = {},
    -- CommonFunctions.lua
    ComFuncs = {
        FileExists = function(file)
            return select(2, AsyncFileOpen(file))
        end,
        TableConcat = TableConcat,
        noop = function()
        end
    },
    ModFuncs = {}
}

local BuildingDefaults = BuildingDefaults
local Mods = Mods
BuildingDefaults._VERSION = Mods[BuildingDefaults.id].version
BuildingDefaults.ModPath = Mods[BuildingDefaults.id].path

do -- Concat
    -- SM has a tendency to inf loop when you return a non-string value that they want to table.concat
    -- so now if i accidentally return say a menu item with a function for a name, it'll just look ugly instead of freezing (cursor moves screen wasd doesn't)
    -- this is also used instead of "str .. str"; anytime you do that lua will hash the new string, and store it till exit (which means this is faster, and uses less memory)
    local TableConcat = BuildingDefaults.ComFuncs.TableConcat
    local concat_table = {}
    function BuildingDefaults.ComFuncs.Concat(...)
        -- reuse old table if it's not that big, else it's quicker to make new one
        -- (should probably bench till i find a good medium rather than just using 500)
        if #concat_table > 500 then
            concat_table = {}
        else
            -- sm devs added a c func to clear tables, which does seem to be faster than a lua loop
            table.iclear(concat_table)
        end
        -- build table from args
        for i = 1, select("#", ...) do
            local concat_value = select(i, ...)
            -- no sense in calling a func more then we need to
            local concat_type = type(concat_value)
            if concat_type == "string" or concat_type == "number" then
                concat_table[i] = concat_value
            else
                concat_table[i] = tostring(concat_value)
            end
        end
        -- and done
        return TableConcat(concat_table)
    end
end
local Concat = BuildingDefaults.ComFuncs.Concat

dofolder_files(Concat(BuildingDefaults.ModPath, "Code/"))
