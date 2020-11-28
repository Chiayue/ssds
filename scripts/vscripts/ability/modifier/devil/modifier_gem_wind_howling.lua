-- 风神之心 集齐风神套装:20%敏捷 射程+200  modifier_gem_wind_howling

if modifier_gem_wind_howling == nil then
	modifier_gem_wind_howling = class({})
end

function modifier_gem_wind_howling:IsHidden()
    if self:GetParent():HasModifier("modifier_gem_wind_howling_additional_attr") then
        return true 
    else
        return false
    end
end

function modifier_gem_wind_howling:OnCreated(params)
    if not IsServer() then return end 
    self:StartIntervalThink(1)
    
end

function modifier_gem_wind_howling:OnIntervalThink(params)
    if not IsServer() then return end 
    local hParent = self:GetParent()
    if hParent:HasModifier("modifier_gem_power_of_aeolus") and not hParent:HasModifier("modifier_gem_wind_howling_additional_attr") then 
        hParent:AddNewModifier(hParent, self:GetAbility(), "modifier_gem_wind_howling_additional_attr", {})
        self:StartIntervalThink(-1)
    end
end

function modifier_gem_wind_howling:IsPurgable()
    return false -- 无法驱散
end
 
function modifier_gem_wind_howling:RemoveOnDeath()
    return false -- 死亡不移除
end

function modifier_gem_wind_howling:GetTexture()
    return "fengshenzhixin"
end