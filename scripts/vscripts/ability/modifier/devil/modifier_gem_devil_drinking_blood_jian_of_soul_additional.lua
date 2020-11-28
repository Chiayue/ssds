--拥有解锁后的饮血剑:全属性+10% modifier_gem_devil_drinking_blood_jian_of_soul_additional

if modifier_gem_devil_drinking_blood_jian_of_soul_additional == nil then
	modifier_gem_devil_drinking_blood_jian_of_soul_additional = class({})
end

function modifier_gem_devil_drinking_blood_jian_of_soul_additional:IsHidden()
    return false
end

function modifier_gem_devil_drinking_blood_jian_of_soul_additional:OnCreated(params)
   
end

function modifier_gem_devil_drinking_blood_jian_of_soul_additional:IsPurgable()
    return false -- 无法驱散
end
 
function modifier_gem_devil_drinking_blood_jian_of_soul_additional:RemoveOnDeath()
    return false -- 死亡不移除
end

function modifier_gem_devil_drinking_blood_jian_of_soul_additional:GetTexture()
    return "yingxuejian-zhen"
end

function modifier_gem_devil_drinking_blood_jian_of_soul_additional:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
    }
    return funcs
end