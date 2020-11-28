-- 腐败  ability_abyss_21
LinkLuaModifier("modifier_ability_abyss_21_passivity", "ability/mechanism_Boss/ability_abyss_21", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ability_abyss_21_debuff", "ability/mechanism_Boss/ability_abyss_21", LUA_MODIFIER_MOTION_NONE)

if ability_abyss_21 == nil then 
    ability_abyss_21 = class({})
end

function ability_abyss_21:IsHidden( ... )
	return true
end

function ability_abyss_21:GetIntrinsicModifierName()
	return "modifier_ability_abyss_21_passivity"
end

if modifier_ability_abyss_21_passivity == nil then 
	modifier_ability_abyss_21_passivity = class({})
end

function modifier_ability_abyss_21_passivity:IsHidden( ... )
	return true
end

function modifier_ability_abyss_21_passivity:DeclareFunctions( ... )
	return{
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
end

function modifier_ability_abyss_21_passivity:OnAttackLanded( keys )
	local attacker = keys.attacker
	local hParent = self:GetParent()
	if attacker:GetTeam() == DOTA_TEAM_BADGUYS then
		return
	end
	if hParent ~= keys.target then 
		return
	end

	local chance = 100

    local nowChance = RandomInt(0,100)
	if nowChance  > chance then
		return 0
    end

    keys.attacker:AddNewModifier(hParent, nil, "modifier_ability_abyss_21_debuff", {duration = 5})
end

if modifier_ability_abyss_21_debuff == nil then 
	modifier_ability_abyss_21_debuff = class({})
end

function modifier_ability_abyss_21_debuff:IsHidden( ... )
	return false
end

function modifier_ability_abyss_21_debuff:DeclareFunctions( ... )
	return{
        MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
	}
end

function modifier_ability_abyss_21_debuff:GetModifierDamageOutgoing_Percentage()
    -- 攻击力变化
	return -15
end

function modifier_ability_abyss_21_debuff:GetModifierAttackSpeedBonus_Constant()
    -- 攻速变化
    return -100
end