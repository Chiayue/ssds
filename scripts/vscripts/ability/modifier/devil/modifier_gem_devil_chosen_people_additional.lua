--拥有力量、敏捷、智力增加:白字全属性额外+7000  modifier_gem_devil_chosen_people_additional

if modifier_gem_devil_chosen_people_additional == nil then
	modifier_gem_devil_chosen_people_additional = class({})
end

function modifier_gem_devil_chosen_people_additional:IsHidden()
    return false
end

function modifier_gem_devil_chosen_people_additional:OnCreated(params)
    if not IsServer() then return end 
    local hParent = self:GetParent()

    local BaseStrength = hParent:GetBaseStrength()
    local BaseAgility = hParent:GetBaseAgility()
    local BaseIntellect = hParent:GetBaseIntellect()
    hParent:SetBaseStrength(BaseStrength + 7000)
    hParent:SetBaseAgility(BaseAgility + 7000)
    hParent:SetBaseIntellect(BaseIntellect + 7000)
end

function modifier_gem_devil_chosen_people_additional:IsPurgable()
    return false -- 无法驱散
end
 
function modifier_gem_devil_chosen_people_additional:RemoveOnDeath()
    return false -- 死亡不移除
end

function modifier_gem_devil_chosen_people_additional:GetTexture()
    return "tianxuanzhiren"
end