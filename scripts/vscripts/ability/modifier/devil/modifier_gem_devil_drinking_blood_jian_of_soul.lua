-- 饮血剑之魂 全属性+10% modifier_gem_devil_drinking_blood_jian_of_soul

if modifier_gem_devil_drinking_blood_jian_of_soul == nil then
	modifier_gem_devil_drinking_blood_jian_of_soul = class({})
end

function modifier_gem_devil_drinking_blood_jian_of_soul:IsHidden()
    if self:GetParent():HasModifier("modifier_gem_devil_drinking_blood_jian_of_soul_additional") then
        return true
    else
        return false
    end
end

function modifier_gem_devil_drinking_blood_jian_of_soul:OnCreated(params)
    if not IsServer() then return end 
    self:StartIntervalThink(1)
    
end

function modifier_gem_devil_drinking_blood_jian_of_soul:OnIntervalThink()
    if not IsServer() then return end 
    local hParent = self:GetParent()
    if hParent:HasModifier("modifier_gem_yinxuejian") and hParent:GetModifierStackCount( "modifier_gem_yinxuejian" , nil ) >= 1250 and not hParent:HasModifier("modifier_gem_devil_drinking_blood_jian_of_soul_additional") then 
        hParent:AddNewModifier(hParent, self:GetAbility(), "modifier_gem_devil_drinking_blood_jian_of_soul_additional", {})
        self:StartIntervalThink(-1)
    end
end

function modifier_gem_devil_drinking_blood_jian_of_soul:IsPurgable()
    return false -- 无法驱散
end
 
function modifier_gem_devil_drinking_blood_jian_of_soul:RemoveOnDeath()
    return false -- 死亡不移除
end

function modifier_gem_devil_drinking_blood_jian_of_soul:GetTexture()
    return "yingxuejianzhihun"
end