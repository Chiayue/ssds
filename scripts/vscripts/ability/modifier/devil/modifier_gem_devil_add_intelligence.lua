-- 智力增加 白字智力+2000 modifier_gem_devil_add_intelligence

if modifier_gem_devil_add_intelligence == nil then
	modifier_gem_devil_add_intelligence = class({})
end

function modifier_gem_devil_add_intelligence:IsHidden()
    local hParent = self:GetParent()
    if hParent:HasModifier("modifier_gem_devil_chosen_people_additional") then  
        return true
    else
        return false
    end
end

function modifier_gem_devil_add_intelligence:OnCreated(params)
    if not IsServer() then return end 
    local hParent = self:GetParent()

    local BaseProperty = hParent:GetBaseIntellect()
    hParent:SetBaseIntellect(BaseProperty + 2000)

    if hParent:HasModifier("modifier_gem_devil_chosen_people") and 
        hParent:HasModifier("modifier_gem_devil_add_agility") and 
        hParent:HasModifier("modifier_gem_devil_add_strength") and not 
        hParent:HasModifier("modifier_gem_devil_chosen_people_additional") then
        hParent:AddNewModifier(hParent, self:GetAbility(), "modifier_gem_devil_chosen_people_additional", {})
    end
end

function modifier_gem_devil_add_intelligence:IsPurgable()
    return false -- 无法驱散
end
 
function modifier_gem_devil_add_intelligence:RemoveOnDeath()
    return false -- 死亡不移除
end

function modifier_gem_devil_add_intelligence:GetTexture()
    return "zhilizhenjia"
end