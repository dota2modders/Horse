require("ai_core")

local DESIRE_NEVER = 1
local DESIRE_AMOVE = 2
local DESIRE_PUNCH = 3
local DESIRE_EARTH_SPLITTER = 4
local DESIRE_BLINK = 5

--Desire hierarchy
--Blink
--Mass earth spliter
--Punch spell
--A move

local targetFocusTime = 0
local targetEnt = nil

function GetTarget()
	local targets = FindUnitsInRadius( DOTA_TEAM_BADGUYS, thisEntity:GetOrigin(), nil, 1000, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, 0, 0, false)

	if targetEnt then
		if GameRules:GetGameTime() < targetFocusTime + 10 then
			return targetEnt
		else		
			for i = 0, #targets, 1 do
				if targets[i]:HasModifier("horse_black_puck_fixate") == false then
					targetEnt = targets[i]
					targetFocusTime = GameRules:GetGameTime()
				else return nil
				end
			end
		end
	elseif #targets > 0 then
		return targets[1]
	end 
end 

----------------------------------------------------------------------------------------------------------

behaviorSystem = {} 

function DispatchOnPostSpawn()
       AddThinkToEnt( thisEntity, "AIThink" )
       behaviorSystem = AICore:CreateBehaviorSystem( { BehaviorNone, BehaviorBlink, BehaviorPunch, BehaviorSplitter, BehaviorAmove } )
end

function AIThink() -- For some reason AddThinkToEnt doesn't accept member functions
       return behaviorSystem:Think()
end

BehaviorNone = {}

function BehaviorNone:Evaluate()
	return DESIRE_NEVER -- must return a value > 0, so we have a default
end

function BehaviorNone:Begin()
	self.duration = 5
	print("NONE!")
	self.endTime = GameRules:GetGameTime() + self.duration
	self.order = 
	{
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_STOP
	}

end

function BehaviorNone:Continue()
	self.duration = 1
end

BehaviorBlink = {}

function BehaviorBlink:Evaluate()
	self.duration = 0.5
	self.endTime = GameRules:GetGameTime() + self.duration
	print("eval..")
	local desire = DESIRE_NEVER

	self.blinkAbility = thisEntity:FindAbilityByName( "horse_blink" )
	self.target = GetTarget()
	print("Checking ability: " .. self.blinkAbility:GetClassname())
	if self.blinkAbility and self.blinkAbility:IsFullyCastable() and self.target then
		desire = DESIRE_BLINK
	end
	print("leaving blink eval")
	return desire
end

function BehaviorBlink:Begin()
	print("BLINKING")

	self.duration = 0.5

	self.order = 
	{
		OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
		UnitIndex = thisEntity:entindex(),
		AbilityIndex = self.blinkAbility:entindex(),
		Position = self.target:GetOrigin()
	}
end

function BehaviorBlink:Think()
	self.order = 
	{
		OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
		UnitIndex = thisEntity:entindex(),
		AbilityIndex = self.blinkAbility:entindex(),
		Position = self.target:GetOrigin()
	}
end

BehaviorBlink.Continue = BehaviorBlink.Begin

BehaviorSplitter = {}

function BehaviorSplitter:Evaluate()
	self.duration = 5
	self.endTime = GameRules:GetGameTime() + self.duration
	local desire = DESIRE_NEVER

	self.splitterAbility = thisEntity:FindAbilityByName( "horse_earth_splitter" )
	self.target = GetTarget()

	if self.splitterAbility and self.splitterAbility:IsFullyCastable() and self.target then
		desire = DESIRE_EARTH_SPLITTER
	end

	return desire
end

function BehaviorSplitter:Begin()
	print("SPLITTING!")
	local targetPosition = self.target:GetOrigin()

	ExecuteOrderFromTable({
		OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
		UnitIndex = thisEntity:entindex(),
		AbilityIndex = self.splitterAbility:entindex(),
		Position = Vec3(targetPosition.x + RandomFloat(20,50), targetPosition.y + RandomFloat(20,50), targetPosition.z)
	})

	ExecuteOrderFromTable({
		OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
		UnitIndex = thisEntity:entindex(),
		AbilityIndex = self.splitterAbility:entindex(),
		Position = Vec3(targetPosition.x + RandomFloat(20,50), targetPosition.y + RandomFloat(20,50), targetPosition.z),
		Queue = true
	})

	ExecuteOrderFromTable({
		OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
		UnitIndex = thisEntity:entindex(),
		AbilityIndex = self.splitterAbility:entindex(),
		Position = Vec3(targetPosition.x + RandomFloat(20,50), targetPosition.y + RandomFloat(20,50), targetPosition.z),
		Queue = true
	})

	ExecuteOrderFromTable({
		OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
		UnitIndex = thisEntity:entindex(),
		AbilityIndex = self.splitterAbility:entindex(),
		Position = Vec3(targetPosition.x + RandomFloat(20,50), targetPosition.y + RandomFloat(20,50), targetPosition.z),
		Queue = true
	})
		
end

BehaviorSplitter.Continue = BehaviorSplitter.Begin

BehaviorPunch = {}

function BehaviorPunch:Evaluate()
	self.duration = 5
	self.endTime = GameRules:GetGameTime() + self.duration
	local desire = DESIRE_NEVER

	self.punchAbility = thisEntity:FindAbilityByName( "horse_punch" )
	self.target = GetTarget()

	if self.punchAbility and self.punchAbility:IsFullyCastable() and self.target then
		desire = DESIRE_PUNCH
	end
	
	return desire
end

function BehaviorPunch:Begin()
	print("PUNCHING!")

	self.order = 
	{
		OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
		UnitIndex = thisEntity:entindex(),
		AbilityIndex = self.punchAbility:entindex(),
		TargetIndex = self.target:entindex()
	}
end

BehaviorPunch.Continue = BehaviorPunch.Begin

BehaviorAmove = {}

function BehaviorAmove:Evaluate()
	self.duration = 5
	self.endTime = GameRules:GetGameTime() + self.duration
	local desire = DESIRE_NEVER

	self.target = GetTarget()

	if self.target then
		desire = DESIRE_AMOVE
	end

	return desire
end

function BehaviorAmove:Begin()
	print("AMOVING!")
	self.order =
	{
		OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE,
		UnitIndex = thisEntity:entindex(),
		Position = self.target:GetOrigin()
	}
end

BehaviorAmove.Continue = BehaviorAmove.Begin
