-- @author undefinist / www.undefinist.com and modified by Blu (/u/IamLUG)
-- Structure of Script Measure:
---- IncFile=
---- Number=
---- SectionName=
---- OptValN= ~
---- (where N is an ordered number from 1)
---- (eg. OptVal1=Meter ~ String)
-- Use %% to substitute it as the iteration number (which is specified by the Number option)
---- For example, if you specify 10, it will create 10 sections and replace the first section's %%
---- with 1, the second section's %% with 2, etc...
-- Wrap any formulas you want to parse in {} that otherwise RM would treat as a string
---- For example, [Measure{%%+1}] will have this script parse it for you

function Initialize()
	local number = SELF:GetNumberOption("Number")
	local sectionName = SELF:GetOption("SectionName")

	local file = io.open(SKIN:MakePathAbsolute(SELF:GetOption("IncFile")), "w")
	
	local t = { "; Auto-generated by " .. SELF:GetName() }
	
	for i=1, number do
		table.insert(t, "\n[" .. ParseFormula(DoSub(sectionName, i)) .. "]")
        local j = 1
        
        while true do
            local result = split(DoSub(SELF:GetOption("OptVal" .. j), i), "~", 2)
            
            if #result < 2 then break end
            
            for k,v in pairs(result) do result[k] = ParseFormula(v) end

            table.insert(t, result[1] .. "=" .. result[2])
            
            j = j + 1
		end
	end
	
	file:write(table.concat(t, "\n"))
	file:close()
end

-- Copied from https://www.lua-users.org/wiki/SplitJoin
-- Added trimming 
function split(str, delim, maxNb)
    -- Eliminate bad cases...
    if string.find(str, delim) == nil then
        return { str }
    end

    if maxNb == nil or maxNb < 1 then 
        maxNb = 0 -- No limit
    end

    local result = {}
    local pat = "(.-)" .. delim .. "()"
    local nb = 0
    local lastPos = 0

    for part, pos in string.gmatch(str, pat) do
        local s = trim(part)

        if s ~= nil and s ~= "" then
            nb = nb + 1
            result[nb] = s
        end

        lastPos = pos

        if(nb == maxNb) then 
            break 
        end
    end

    if nb ~= maxNb then
        result[nb + 1] = trim(str:sub(lastPos))
    end

    return result
end

-- Copied from https://lua-users.org/wiki/CommonFunctions
-- remove trailing and leading whitespace from string
-- https://en.wikipedia.org/wiki/Trim_(programming)
function trim(s)
    -- from PiL2 20.4
    return s:gsub("^%s*(.-)%s*$", "%1")
end

function DoSub(str, i)
    return str:gsub("%%%%", i)
end

function ParseFormula(str)
    return str:gsub("{.-}", function(f) return SKIN:ParseFormula("(" .. f:sub(2,-2) .. ")") end)
end
