-- 敏捷增加 白字敏捷+2000 modifier_gem_devil_add_agility

if modifier_gem_devil_add_agility == nil then
	modifier_gem_devil_add_agility = class({})
end

function modifier_gem_devil_add_agility:IsHidden()
    local hParent = self:GetParent()
    if hParent:HasModifier("modifier_gem_devil_chosen_people_additional") then  
        return true
    else
        return false
    end
end

function modifier_gem_devil_add_agility:OnCreated(params)
    if not IsServer() then return end 
    local hParent = self:GetParent()

    local BaseProperty = hParent:GetBaseAgility() 
    hParent:SetBaseAgility(BaseProperty + 2000)

    if hParent:HasModifier("modifier_gem_devil_chosen_people") and 
        hParent:HasModifier("modifier_gem_devil_add_strength") and 
        hParent:HasModifier("modifier_gem_devil_add_intelligence") and not 
        hParent:HasModifier("modifier_gem_devil_chosen_people_additional") then
        hParent:AddNewModifier(hParent, self:GetAbility(), "modifier_gem_devil_chosen_people_additional", {})
    end
end

function modifier_gem_devil_add_agility:IsPurgable()
    return false -- 无法驱散
end
 
function modifier_gem_devil_add_agility:RemoveOnDeath()
    return false -- 死亡不移除
end

function modifier_gem_devil_add_agility:GetTexture()
    return "mingjiezhenjia"
end