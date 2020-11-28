-- 解锁匠神之心 modifier_gem_as_divine_wrath_additional_attr

if modifier_gem_as_divine_wrath_additional_attr == nil then
	modifier_gem_as_divine_wrath_additional_attr = class({})
end

function modifier_gem_as_divine_wrath_additional_attr:IsPurgable()
    return false -- 无法驱散
end
 
function modifier_gem_as_divine_wrath_additional_attr:RemoveOnDeath()
    return false -- 死亡不移除
end

function modifier_gem_as_divine_wrath_additional_attr:GetTexture()
    return "jiangshenzhinu"
end

function modifier_gem_as_divine_wrath_additional_attr:IsHidden()
    return false 
end
function modifier_gem_as_divine_wrath_additional_attr:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
        MODIFIER_PROPERTY_EXTRA_HEALTH_BONUS,
    }
    return funcs
end

function modifier_gem_as_divine_wrath_additional_attr:GetModifierExtraHealthBonus()
    return self:GetParent():GetMaxHealth() * 0.2
end