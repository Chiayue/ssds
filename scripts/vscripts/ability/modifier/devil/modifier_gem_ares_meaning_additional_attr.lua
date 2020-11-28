-- 解锁战神之心 modifier_gem_ares_meaning_additional_attr

if modifier_gem_ares_meaning_additional_attr == nil then
	modifier_gem_ares_meaning_additional_attr = class({})
end

function modifier_gem_ares_meaning_additional_attr:IsPurgable()
    return false -- 无法驱散
end
 
function modifier_gem_ares_meaning_additional_attr:RemoveOnDeath()
    return false -- 死亡不移除
end

function modifier_gem_ares_meaning_additional_attr:GetTexture()
    return "zhanshenzhiyi"
end

function modifier_gem_ares_meaning_additional_attr:IsHidden()
    return false 
end

function modifier_gem_ares_meaning_additional_attr:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
        MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,
    }
    return funcs
end

function modifier_gem_ares_meaning_additional_attr:GetModifierDamageOutgoing_Percentage( ... )
    return 20 
end
