if modifier_gem_devilzhili == nil then
	modifier_gem_devilzhili = class({})
end

function modifier_gem_devilzhili:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
    }
    return funcs
end

function modifier_gem_devilzhili:IsHidden()
	return false
end

function modifier_gem_devilzhili:OnCreated(params)
    self.attribute_promotion = 6666
end

--力量
function modifier_gem_devilzhili:GetModifierBonusStats_Strength()
    return self.attribute_promotion
end

--智力
function modifier_gem_devilzhili:GetModifierBonusStats_Intellect()
    return self.attribute_promotion
end

--敏捷
function modifier_gem_devilzhili:GetModifierBonusStats_Agility()
    return self.attribute_promotion
end

function modifier_gem_devilzhili:IsPurgable()
    return false -- 无法驱散
end
 
function modifier_gem_devilzhili:RemoveOnDeath()
    return false -- 死亡不移除
end

function modifier_gem_devilzhili:GetTexture()
    return "baowu/devil_power"
end