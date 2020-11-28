-- 匠神之心 集齐匠神套装:20%智力 20%额外生命 modifier_gem_as_divine_wrath

if modifier_gem_as_divine_wrath == nil then
	modifier_gem_as_divine_wrath = class({})
end

function modifier_gem_as_divine_wrath:IsHidden()
    if self:GetParent():HasModifier("modifier_gem_as_divine_wrath_additional_attr") then
        return true 
    else
        return false
    end
end

function modifier_gem_as_divine_wrath:OnCreated(params)
    if not IsServer() then return end 
    self:StartIntervalThink(1)
end

function modifier_gem_as_divine_wrath:OnIntervalThink(params)
    if not IsServer() then return end 
    local hParent = self:GetParent()
    if hParent:HasModifier("modifier_gem_blacksmith_power") and not hParent:HasModifier("modifier_gem_as_divine_wrath_additional_attr") then 
        hParent:AddNewModifier(hParent, self:GetAbility(), "modifier_gem_as_divine_wrath_additional_attr", {})
        self:StartIntervalThink(-1)
    end
end

function modifier_gem_as_divine_wrath:IsPurgable()
    return false -- 无法驱散
end
 
function modifier_gem_as_divine_wrath:RemoveOnDeath()
    return false -- 死亡不移除
end

function modifier_gem_as_divine_wrath:GetTexture()
    return "jiangshenzhixin"
end