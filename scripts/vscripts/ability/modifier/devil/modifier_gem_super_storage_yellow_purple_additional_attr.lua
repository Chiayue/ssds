-- 超级黄紫：需拥有超级黄、超级紫、黄紫套才能触发

if modifier_gem_super_storage_yellow_purple_additional_attr == nil then
	modifier_gem_super_storage_yellow_purple_additional_attr = class({})
end

function modifier_gem_super_storage_yellow_purple_additional_attr:IsHidden()
        return false 
end

function modifier_gem_super_storage_yellow_purple_additional_attr:IsPurgable()
    return false -- 无法驱散
end
 
function modifier_gem_super_storage_yellow_purple_additional_attr:RemoveOnDeath()
    return false -- 死亡不移除
end

function modifier_gem_super_storage_yellow_purple_additional_attr:GetTexture()
    return "chaojichubei-zihuang"
end

function modifier_gem_super_storage_yellow_purple_additional_attr:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
    }
    return funcs
end

function modifier_gem_super_storage_yellow_purple_additional_attr:GetModifierBonusStats_Strength()
    return 10000
end

function modifier_gem_super_storage_yellow_purple_additional_attr:GetModifierBonusStats_Agility()
    return 10000
end

function modifier_gem_super_storage_yellow_purple_additional_attr:GetModifierBonusStats_Intellect()
    return 10000
end