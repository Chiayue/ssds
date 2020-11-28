--拥有残败之刃:移除残败之刃，物理爆伤+300%  modifier_gem_falling_of_sword_additional

if modifier_gem_falling_of_sword_additional == nil then
	modifier_gem_falling_of_sword_additional = class({})
end

function modifier_gem_falling_of_sword_additional:IsHidden()
    return false  
end

function modifier_gem_falling_of_sword_additional:IsPurgable()
    return false -- 无法驱散
end
 
function modifier_gem_falling_of_sword_additional:RemoveOnDeath()
    return false -- 死亡不移除
end

function modifier_gem_falling_of_sword_additional:GetTexture()
    return "canbaishengjian-zhen"
end

function modifier_gem_falling_of_sword_additional:DeclareFunctions()
    local funcs = {
        -- MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        -- MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
        -- MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
    }
    return funcs
end