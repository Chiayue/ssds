if modifier_gem_liliangcuncu == nil then
	modifier_gem_liliangcuncu = class({})
end

function modifier_gem_liliangcuncu:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
    }
    return funcs
end

function modifier_gem_liliangcuncu:IsHidden()
	return false
end

function modifier_gem_liliangcuncu:OnCreated(params)
    self.attribute_promotion = 2000
end

--力量
function modifier_gem_liliangcuncu:GetModifierBonusStats_Strength()
    return self.attribute_promotion
end

--智力
function modifier_gem_liliangcuncu:GetModifierBonusStats_Intellect()
    return self.attribute_promotion
end

--敏捷
function modifier_gem_liliangcuncu:GetModifierBonusStats_Agility()
    return self.attribute_promotion
end

function modifier_gem_liliangcuncu:IsPurgable()
    return false -- 无法驱散
end
 
function modifier_gem_liliangcuncu:RemoveOnDeath()
    return false -- 死亡不移除
end

function modifier_gem_liliangcuncu:GetTexture()
    return "baowu/liliangcunchu"
end