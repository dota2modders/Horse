-- This chunk of code forces the reloading of all modules when we reload script.
if g_reloadState == nil then
	g_reloadState = {}
	for k,v in pairs( package.loaded ) do
		g_reloadState[k] = v
	end
else
	for k,v in pairs( package.loaded ) do
		if g_reloadState[k] == nil then
			package.loaded[k] = nil
		end
	end
end

-- A function to re-lookup a function by name every time.
function Dynamic_Wrap ( mt, name )
	if Convars:GetFloat( 'developer' ) == 1 then
		local function w(...) return mt[name](...) end
		return w
	else
		return mt[name]
	end
end
local df = false

function HandleOrder(order)
	return df;
end

--ExHook:ExecuteOrders(HandleOrder)
	 Convars:RegisterCommand('rv', function(name)
        -- Check if the server ran it
        df = not df
    end, '', 0)

    Convars:RegisterCommand('hook', function(name)
        -- Check if the server ran it
   --     ExHook:ExecuteOrders(HandleOrder)
    end, '', 0)

        Convars:RegisterCommand('black', function(name)
        -- Check if the server ran it
        local hero = Convars:GetCommandClient():GetAssignedHero()
        print(hero:GetClassname())
        print(hero:GetOrigin())
        CreateUnitByName("npc_dota_creature_black_puck", hero:GetOrigin(), true, nil, nil, DOTA_TEAM_BADGUYS)

    end, '', 0)

print("HORSE LOADED")

require("horse")
require("ai_core")
require("util")