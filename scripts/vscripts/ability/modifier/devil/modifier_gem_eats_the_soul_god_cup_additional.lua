--拥有噬魂圣杯:移除噬魂圣杯 法术爆伤+300% modifier_gem_eats_the_soul_god_cup_additional

if modifier_gem_eats_the_soul_god_cup_additional == nil then
	modifier_gem_eats_the_soul_god_cup_additional = class({})
end

function modifier_gem_eats_the_soul_god_cup_additional:IsHidden()
    return false  
end

function modifier_gem_eats_the_soul_god_cup_additional:IsPurgable()
    return false -- 无法驱散
end
 
function modifier_gem_eats_the_soul_god_cup_additional:RemoveOnDeath()
    return false -- 死亡不移除
end

function modifier_gem_eats_the_soul_god_cup_additional:GetTexture()
    return "shihunshengbei-zhen"
end

function modifier_gem_eats_the_soul_god_cup_additional:DeclareFunctions()
    local funcs = {
        -- MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        -- MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
        -- MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
    }
    return funcs
end