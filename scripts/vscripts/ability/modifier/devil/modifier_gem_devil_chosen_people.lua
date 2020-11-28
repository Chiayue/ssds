-- 天选之人 白字全属性+3000 拥有力量、敏捷、智力增加 白字全属性额外+7000 modifier_gem_devil_chosen_people

if modifier_gem_devil_chosen_people == nil then
	modifier_gem_devil_chosen_people = class({})
end

function modifier_gem_devil_chosen_people:IsHidden()

    if self:GetParent():HasModifier("modifier_gem_devil_chosen_people_additional") then
        return true
    else
        return false
    end
end

function modifier_gem_devil_chosen_people:OnCreated(params)
    if not IsServer() then return end 
    local hParent = self:GetParent()

    local BaseStrength = hParent:GetBaseStrength()
    local BaseAgility = hParent:GetBaseAgility()
    local BaseIntellect = hParent:GetBaseIntellect()

    hParent:SetBaseStrength(BaseStrength + 3000)
    hParent:SetBaseAgility(BaseAgility + 3000)
    hParent:SetBaseIntellect(BaseIntellect + 3000)
    if hParent:HasModifier("modifier_gem_devil_add_strength") and 
        hParent:HasModifier("modifier_gem_devil_add_agility") and 
        hParent:HasModifier("modifier_gem_devil_add_intelligence") and not 
        hParent:HasModifier("modifier_gem_devil_chosen_people_additional") then
        hParent:AddNewModifier(hParent, self:GetAbility(), "modifier_gem_devil_chosen_people_additional", {})
    end
end

function modifier_gem_devil_chosen_people:IsPurgable()
    return false -- 无法驱散
end
 
function modifier_gem_devil_chosen_people:RemoveOnDeath()
    return false -- 死亡不移除
end

function modifier_gem_devil_chosen_people:GetTexture()
    return "tianxuanzhiren"
end