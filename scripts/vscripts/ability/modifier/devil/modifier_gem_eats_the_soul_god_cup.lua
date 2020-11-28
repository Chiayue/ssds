-- 噬魂神杯 法术爆伤+50% modifier_gem_eats_the_soul_god_cup

if modifier_gem_eats_the_soul_god_cup == nil then
	modifier_gem_eats_the_soul_god_cup = class({})
end

function modifier_gem_eats_the_soul_god_cup:IsHidden()
    if self:GetParent():HasModifier( "modifier_gem_eats_the_soul_god_cup_additional" ) then
        return true
    else
        return false
    end
end

function modifier_gem_eats_the_soul_god_cup:OnCreated(params)
    if not IsServer() then return end 
    self:StartIntervalThink(1)
end

function modifier_gem_eats_the_soul_god_cup:OnIntervalThink(params)
    if not IsServer() then return end 
    local hParent = self:GetParent()
    if hParent:HasModifier("modifier_gem_shihunshengbei") and not hParent:HasModifier("modifier_gem_eats_the_soul_god_cup_additional") then
        hParent:AddNewModifier(hParent, self:GetAbility(), "modifier_gem_eats_the_soul_god_cup_additional", {})
        hParent:RemoveModifierByName("modifier_gem_shihunshengbei")
        hParent:RemoveModifierByName("modifier_gem_eats_the_soul_god_cup")
        self:StartIntervalThink(-1)
    end
end

function modifier_gem_eats_the_soul_god_cup:IsPurgable()
    return false -- 无法驱散
end
 
function modifier_gem_eats_the_soul_god_cup:RemoveOnDeath()
    return false -- 死亡不移除
end

function modifier_gem_eats_the_soul_god_cup:GetTexture()
    return "shihunshengbeiII"
end