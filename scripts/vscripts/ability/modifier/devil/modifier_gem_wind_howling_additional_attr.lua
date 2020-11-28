-- 解锁风神之心 modifier_gem_wind_howling_additional_attr

if modifier_gem_wind_howling_additional_attr == nil then
	modifier_gem_wind_howling_additional_attr = class({})
end

function modifier_gem_wind_howling_additional_attr:IsPurgable()
    return false -- 无法驱散
end
 
function modifier_gem_wind_howling_additional_attr:RemoveOnDeath()
    return false -- 死亡不移除
end

function modifier_gem_wind_howling_additional_attr:GetTexture()
    return "fengshenzhixiao"
end

function modifier_gem_wind_howling_additional_attr:IsHidden()
    return false 
end
function modifier_gem_wind_howling_additional_attr:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
        MODIFIER_PROPERTY_ATTACK_RANGE_BONUS, -- 射程
    }
    return funcs
end

function modifier_gem_wind_howling_additional_attr:GetModifierAttackRangeBonus()
    return 200
end