-- 激活力量爆炸 modifier_gem_strength_explode_additional

if modifier_gem_strength_explode_additional == nil then
	modifier_gem_strength_explode_additional = class({})
end

function modifier_gem_strength_explode_additional:IsHidden()
    return false
end

function modifier_gem_strength_explode_additional:OnCreated(params)
   
end

function modifier_gem_strength_explode_additional:IsPurgable()
    return false -- 无法驱散
end
 
function modifier_gem_strength_explode_additional:RemoveOnDeath()
    return false -- 死亡不移除
end

function modifier_gem_strength_explode_additional:GetTexture()
    return "liliangbaozha"
end

function modifier_gem_strength_explode_additional:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        -- MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
        -- MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
    }
    return funcs
end