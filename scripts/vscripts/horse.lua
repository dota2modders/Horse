-- Reload support apparently
if HorseGameMode == nil then
    HorseGameMode = {}
    HorseGameMode.szEntityClassName = "horse"
    HorseGameMode.szNativeClassName = "dota_base_game_mode"
    HorseGameMode.__index = HorseGameMode
end

function HorseGameMode:new (o)
	o = o or {}
	setmetatable(o, self)
	return o
end

-- Called from C++ to Initialize
function HorseGameMode:InitGameMode()

    Convars:RegisterCommand('toggle_sliding', function()
        local cmdPlayer = Convars:GetCommandClient()
        if cmdPlayer then
            local hero = cmdPlayer:GetAssignedHero()
            if hero then
                --modifier_ice_slide
				if hero:HasModifier('modifier_ice_slide') then
					hero:RemoveModifierByName('modifier_ice_slide')
				else
					hero:AddNewModifier( hero, nil, 'modifier_ice_slide', {})
				end
                return
            end
        end
    end, 'toggle sliding for player', 0)

	GameRules:SetHeroRespawnEnabled( true )
	GameRules:SetUseUniversalShopMode( false )
	GameRules:SetHeroSelectionTime( 30.0 )
	GameRules:SetPreGameTime( 60.0 )
	GameRules:SetPostGameTime( 60.0 )
	GameRules:SetTreeRegrowTime( 10.0 )
	GameRules:SetHeroMinimapIconSize( 400 )
	GameRules:SetCreepMinimapIconScale( 0.7 )
	GameRules:SetRuneMinimapIconScale( 0.7 )
	
	GameRules:SetSameHeroSelectionEnabled( true )
	
	GameRules:SetTimeOfDay( 0.0 )
	Convars:SetBool( "dota_force_night", false )
	Convars:SetBool( "dota_suppress_invalid_orders", false )
	
	self._scriptBind:BeginThink( "HorseThink", Dynamic_Wrap( HorseGameMode, 'Think' ), 0.25 )
	
	ListenToGameEvent( 'player_connect_full', Dynamic_Wrap( HorseGameMode, 'AutoAssignPlayer' ), self )

end

-- Think function called from C++, every second.
function HorseGameMode:Think()
	-- If the game's over, it's over.
	if GameRules:State_Get() >= DOTA_GAMERULES_STATE_POST_GAME then
		self._scriptBind:EndThink( "GameThink" )
		return
	end
end

-- Auto assigns a player when they connect
function HorseGameMode:AutoAssignPlayer(keys)
    -- Grab the entity index of this player
	local entIndex = keys.index+1
	local ply = EntIndexToHScript(entIndex)

	ply:SetTeam(DOTA_TEAM_GOODGUYS)
	ply:__KeyValueFromInt('teamnumber', DOTA_TEAM_GOODGUYS)

    -- Autoassign player
	CreateHeroForPlayer('npc_dota_hero_viper', ply)
end

EntityFramework:RegisterScriptClass( HorseGameMode )