if ability_zibi_boss == nil then
	ability_zibi_boss = class({})
end
LinkLuaModifier( "modifier_ability_zibi_boss", "ability/creatures/ability_zibi_boss.lua", LUA_MODIFIER_MOTION_NONE )

function ability_zibi_boss:GetIntrinsicModifierName()
	return "modifier_ability_zibi_boss"
end

--------------------------------------------------------------------------------

if modifier_ability_zibi_boss == nil then
	modifier_ability_zibi_boss = class({})
end

function modifier_ability_zibi_boss:IsHidden()
	return false
end

function modifier_ability_zibi_boss:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_ability_zibi_boss:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE ,     --移动速度（百分比增加移动速度，自身不叠加）
    }
    return funcs
end

--移动速度（百分比增加移动速度，自身不叠加） +150%  （350点移动速度）
function modifier_ability_zibi_boss:GetModifierMoveSpeedBonus_Percentage()
    return 180
end