-- 大法师之魂 全属性+100 集齐黑暗大法师=额外增加66%全属性

if modifier_gem_ripple_devil == nil then
	modifier_gem_ripple_devil = class({})
end

function modifier_gem_ripple_devil:IsHidden()
    if self:GetParent():HasModifier("modifier_gem_ripple_devil_additional_attr") then
        return true 
    else
        return false
    end
end

function modifier_gem_ripple_devil:OnCreated(params)
    if not IsServer() then return end
    self:StartIntervalThink(1)
end

function modifier_gem_ripple_devil:OnIntervalThink(params)
    if not IsServer() then return end
    local hParent = self:GetParent()
    if hParent:HasModifier("modifier_gem_devilzhili") and not hParent:HasModifier("modifier_gem_ripple_devil_additional_attr") then 
        hParent:AddNewModifier(hParent, self:GetAbility(), "modifier_gem_ripple_devil_additional_attr", {})
        self:StartIntervalThink(-1)
    end
end

function modifier_gem_ripple_devil:IsPurgable()
    return false -- 无法驱散
end
 
function modifier_gem_ripple_devil:RemoveOnDeath()
    return false -- 死亡不移除
end

function modifier_gem_ripple_devil:GetTexture()
    return "dafashizhihun"
end

function modifier_gem_ripple_devil:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
    }
    return funcs
end

function modifier_gem_ripple_devil:GetModifierBonusStats_Strength()
    return 100
end

function modifier_gem_ripple_devil:GetModifierBonusStats_Agility()
    return 100 
end

function modifier_gem_ripple_devil:GetModifierBonusStats_Intellect()
    return 100
end