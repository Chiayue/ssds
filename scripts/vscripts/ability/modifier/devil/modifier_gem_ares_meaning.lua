-- 战神之心 集齐战神套装：额外力量+20%，攻击力20%  modifier_gem_ares_meaning

if modifier_gem_ares_meaning == nil then
	modifier_gem_ares_meaning = class({})
end

function modifier_gem_ares_meaning:IsHidden()
    if self:GetParent():HasModifier("modifier_gem_ares_meaning_additional_attr") then 
        return true 
    else
        return false
    end
end

function modifier_gem_ares_meaning:OnCreated(params)
    if not IsServer() then return end 
    self:StartIntervalThink(1)
end

function modifier_gem_ares_meaning:OnIntervalThink(params)
    if not IsServer() then return end 
    local hParent = self:GetParent()
    if hParent:HasModifier("modifier_gem_god_hand") and not hParent:HasModifier("modifier_gem_ares_meaning_additional_attr") then 
        hParent:AddNewModifier(hParent, self:GetAbility(), "modifier_gem_ares_meaning_additional_attr", {})
        self:StartIntervalThink(-1)
    end
end

function modifier_gem_ares_meaning:IsPurgable()
    return false -- 无法驱散
end
 
function modifier_gem_ares_meaning:RemoveOnDeath()
    return false -- 死亡不移除
end

function modifier_gem_ares_meaning:GetTexture()
    return "zhanshenzhixin"
end