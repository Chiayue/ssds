-- 突进 ability_abyss_20
LinkLuaModifier("modifier_ability_abyss_20_passivity", "ability/mechanism_Boss/ability_abyss_20", LUA_MODIFIER_MOTION_NONE)

if ability_abyss_20 == nil then 
    ability_abyss_20 = class({})
end

function ability_abyss_20:IsHidden( ... )
	return true
end

-- function ability_abyss_20:OnSpellStart()
--     local vPos = hParent:GetAbsOrigin() + hParent:GetForwardVector() * 500

-- 	FindClearSpaceForUnit(hParent, vPos, false)
-- end

function ability_abyss_20:GetIntrinsicModifierName()
	return "modifier_ability_abyss_20_passivity"
end

if modifier_ability_abyss_20_passivity == nil then 
	modifier_ability_abyss_20_passivity = class({})
end

function modifier_ability_abyss_20_passivity:IsHidden( ... )
	return true
end

function modifier_ability_abyss_20_passivity:DeclareFunctions( ... )
	return{
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
end

function modifier_ability_abyss_20_passivity:OnAttackLanded( keys )
	local attacker = keys.attacker
	local hParent = self:GetParent()
	if attacker:GetTeam() == DOTA_TEAM_BADGUYS then
		return
	end
	if hParent ~= keys.target then 
		return
	end

	local chance = 30

    local nowChance = RandomInt(0,100)
	if nowChance  > chance then
		return 0
    end

    local vPos = hParent:GetAbsOrigin() + hParent:GetForwardVector() * 500

	FindClearSpaceForUnit(hParent, vPos, false)
end