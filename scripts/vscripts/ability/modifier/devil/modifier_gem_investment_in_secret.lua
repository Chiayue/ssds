-- 投资秘籍 投资收益+10%(乘算) 投资收益额外+10% modifier_gem_investment_in_secret

if modifier_gem_investment_in_secret == nil then
	modifier_gem_investment_in_secret = class({})
end

function modifier_gem_investment_in_secret:IsHidden()
    if self:GetParent():HasModifier( "modifier_gem_investment_in_secret_additional" ) then
        return true
    else
        return false
    end
end

function modifier_gem_investment_in_secret:OnCreated(params)
    if not IsServer() then return end 
    self:StartIntervalThink(1)
end

function modifier_gem_investment_in_secret:OnIntervalThink(params)
    if not IsServer() then return end 
    local hParent = self:GetParent()
    if hParent:HasModifier("modifier_gem_zuanshi_touzi") and not hParent:HasModifier("modifier_gem_investment_in_secret_additional") then
        hParent:AddNewModifier(hParent, self:GetAbility(), "modifier_gem_investment_in_secret_additional", {})
        self:StartIntervalThink(-1)
    end
end

function modifier_gem_investment_in_secret:IsPurgable()
    return false -- 无法驱散
end
 
function modifier_gem_investment_in_secret:RemoveOnDeath()
    return false -- 死亡不移除
end

function modifier_gem_investment_in_secret:GetTexture()
    return "touzimiji"
end