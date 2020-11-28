-- 力量增加 白字力量+2000 modifier_gem_devil_add_strength

if modifier_gem_devil_add_strength == nil then
	modifier_gem_devil_add_strength = class({})
end

function modifier_gem_devil_add_strength:IsHidden()
    local hParent = self:GetParent()
    if hParent:HasModifier("modifier_gem_devil_chosen_people_additional") then  
        return true
    else
        return false
    end
end

function modifier_gem_devil_add_strength:OnCreated(params)
    if not IsServer() then return end 
    local hParent = self:GetParent()

    local BaseProperty = hParent:GetBaseStrength() 
    hParent:SetBaseStrength(BaseProperty + 2000)

    if hParent:HasModifier("modifier_gem_devil_chosen_people") and 
        hParent:HasModifier("modifier_gem_devil_add_agility") and 
        hParent:HasModifier("modifier_gem_devil_add_intelligence") and not 
        hParent:HasModifier("modifier_gem_devil_chosen_people_additional") then
        hParent:AddNewModifier(hParent, self:GetAbility(), "modifier_gem_devil_chosen_people_additional", {})
    end
end

function modifier_gem_devil_add_strength:IsPurgable()
    return false -- 无法驱散
end
 
function modifier_gem_devil_add_strength:RemoveOnDeath()
    return false -- 死亡不移除
end

function modifier_gem_devil_add_strength:GetTexture()
    return "liliangzhengjia"
end