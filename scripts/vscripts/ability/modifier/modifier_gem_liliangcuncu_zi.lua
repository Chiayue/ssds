if modifier_gem_liliangcuncu_zi == nil then
	modifier_gem_liliangcuncu_zi = class({})
end

function modifier_gem_liliangcuncu_zi:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
    }
    return funcs
end

function modifier_gem_liliangcuncu_zi:IsHidden()
	if self:GetCaster():HasModifier( "modifier_gem_liliangcuncu" ) then
        return true
    else
        return false
    end
end

function modifier_gem_liliangcuncu_zi:OnCreated(params)
    self.attribute_promotion = -100

    local hero = self:GetParent()
    if hero:HasModifier("modifier_gem_liliangcuncu_huang") and not hero:HasModifier("modifier_gem_liliangcuncu") then
        hero:AddNewModifier( hero, nil, "modifier_gem_liliangcuncu", {} )
    end
end

--力量
function modifier_gem_liliangcuncu_zi:GetModifierBonusStats_Strength()
    return self.attribute_promotion
end

--智力
function modifier_gem_liliangcuncu_zi:GetModifierBonusStats_Intellect()
    return self.attribute_promotion
end

--敏捷
function modifier_gem_liliangcuncu_zi:GetModifierBonusStats_Agility()
    return self.attribute_promotion
end

function modifier_gem_liliangcuncu_zi:IsPurgable()
    return false -- 无法驱散
end
 
function modifier_gem_liliangcuncu_zi:RemoveOnDeath()
    return false -- 死亡不移除
end

function modifier_gem_liliangcuncu_zi:GetTexture()
    return "baowu/liliangcunchu-zi"
end