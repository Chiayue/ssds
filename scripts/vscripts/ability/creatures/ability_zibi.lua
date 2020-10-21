if ability_zibi == nil then
	ability_zibi = class({})
end
LinkLuaModifier( "modifier_ability_zibi", "ability/creatures/ability_zibi.lua", LUA_MODIFIER_MOTION_NONE )

function ability_zibi:GetIntrinsicModifierName()
	return "modifier_ability_zibi"
end

--------------------------------------------------------------------------------

if modifier_ability_zibi == nil then
	modifier_ability_zibi = class({})
end

function modifier_ability_zibi:IsHidden()
	return false
end

function modifier_ability_zibi:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_ability_zibi:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE ,     --移动速度（百分比增加移动速度，自身不叠加）
    }
    return funcs
end

--移动速度（百分比增加移动速度，自身不叠加） +80%  （200点移动速度）
function modifier_ability_zibi:GetModifierMoveSpeedBonus_Percentage()
    return 80
end