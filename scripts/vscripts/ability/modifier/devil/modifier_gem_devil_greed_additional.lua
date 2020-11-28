-- 拥有贪婪宝物触发:贪婪时35%额外增加一次

if modifier_gem_devil_greed_additional == nil then
	modifier_gem_devil_greed_additional = class({})
end

function modifier_gem_devil_greed_additional:IsHidden()
        return false  
end

function modifier_gem_devil_greed_additional:IsPurgable()
    return false -- 无法驱散
end
 
function modifier_gem_devil_greed_additional:RemoveOnDeath()
    return false -- 死亡不移除
end

function modifier_gem_devil_greed_additional:GetTexture()
    return "tandewuyan"
end

function modifier_gem_devil_greed_additional:DeclareFunctions()
    local funcs = {
        -- MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        -- MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
        -- MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
    }
    return funcs
end