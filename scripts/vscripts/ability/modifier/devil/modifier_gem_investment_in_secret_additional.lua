-- 拥有钻石投资:投资收益额外+10%   modifier_gem_investment_in_secret_additional

if modifier_gem_investment_in_secret_additional == nil then
	modifier_gem_investment_in_secret_additional = class({})
end

function modifier_gem_investment_in_secret_additional:IsHidden()
    return false  
end

function modifier_gem_investment_in_secret_additional:IsPurgable()
    return false -- 无法驱散
end
 
function modifier_gem_investment_in_secret_additional:RemoveOnDeath()
    return false -- 死亡不移除
end

function modifier_gem_investment_in_secret_additional:GetTexture()
    return "touzidashi"
end

function modifier_gem_investment_in_secret_additional:DeclareFunctions()
    local funcs = {
        -- MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        -- MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
        -- MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
    }
    return funcs
end