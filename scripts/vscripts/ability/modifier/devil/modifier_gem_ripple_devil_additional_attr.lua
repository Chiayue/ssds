-- 解锁大法师之魂 modifier_gem_ripple_devil_additional_attr

if modifier_gem_ripple_devil_additional_attr == nil then
	modifier_gem_ripple_devil_additional_attr = class({})
end

function modifier_gem_ripple_devil_additional_attr:IsPurgable()
    return false -- 无法驱散
end
 
function modifier_gem_ripple_devil_additional_attr:RemoveOnDeath()
    return false -- 死亡不移除
end

function modifier_gem_ripple_devil_additional_attr:GetTexture()
    return "wangzhili"
end

function modifier_gem_ripple_devil_additional_attr:IsHidden()
    return false
end

function modifier_gem_ripple_devil_additional_attr:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
    }
    return funcs
end