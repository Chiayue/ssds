-- 超级存储：黄 全属性-2000，集齐【黄】【紫】【超级黄】【超级紫】后，额外全属性+10000，全属性+30% modifier_gem_super_storage_yellow

if modifier_gem_super_storage_yellow == nil then
	modifier_gem_super_storage_yellow = class({})
end

function modifier_gem_super_storage_yellow:IsHidden()
    if self:GetParent():HasModifier( "modifier_gem_super_storage_yellow_purple_additional_attr" ) then
        return true
    else
        return false
    end
end

function modifier_gem_super_storage_yellow:OnCreated(params)
    if not IsServer() then return end 
    self:StartIntervalThink(1)
end

function modifier_gem_super_storage_yellow:OnIntervalThink(params)
    if not IsServer() then return end 
    local hParent = self:GetParent()
    if hParent:HasModifier("modifier_gem_liliangcuncu") and hParent:HasModifier("modifier_gem_super_storage_purple") and not hParent:HasModifier("modifier_gem_super_storage_yellow_purple_additional_attr") then 
        hParent:AddNewModifier(hParent, self:GetAbility(), "modifier_gem_super_storage_yellow_purple_additional_attr", {})
        self:StartIntervalThink(-1)
    end
end

function modifier_gem_super_storage_yellow:IsPurgable()
    return false -- 无法驱散
end
 
function modifier_gem_super_storage_yellow:RemoveOnDeath()
    return false -- 死亡不移除
end

function modifier_gem_super_storage_yellow:GetTexture()
    return "chaojichubei-huang"
end

function modifier_gem_super_storage_yellow:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
    }
    return funcs
end

function modifier_gem_super_storage_yellow:GetModifierBonusStats_Strength()
    return -2000
end

function modifier_gem_super_storage_yellow:GetModifierBonusStats_Agility()
    return -2000
end

function modifier_gem_super_storage_yellow:GetModifierBonusStats_Intellect()
    return -2000
end