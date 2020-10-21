if modifier_gem_devil_left_hand == nil then
	modifier_gem_devil_left_hand = class({})
end

function modifier_gem_devil_left_hand:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
    }
    return funcs
end

function modifier_gem_devil_left_hand:IsHidden()
	if self:GetCaster():HasModifier( "modifier_gem_devilzhili" ) then
        return true
    else
        return false
    end
end

function modifier_gem_devil_left_hand:OnCreated(params)
    self.attribute_promotion = 100

    if IsServer() then
        local hero = self:GetParent()
        if hero:HasModifier("modifier_gem_devil_head") and hero:HasModifier("modifier_gem_devil_right_foot") and hero:HasModifier("modifier_gem_devil_right_hand") and hero:HasModifier("modifier_gem_devil_left_foot") and not hero:HasModifier("modifier_gem_devilzhili") then
            hero:AddNewModifier( hero, nil, "modifier_gem_devilzhili", {} )
        end
    end
end

--力量
function modifier_gem_devil_left_hand:GetModifierBonusStats_Strength()
    return self.attribute_promotion
end

--智力
function modifier_gem_devil_left_hand:GetModifierBonusStats_Intellect()
    return self.attribute_promotion
end

--敏捷
function modifier_gem_devil_left_hand:GetModifierBonusStats_Agility()
    return self.attribute_promotion
end

function modifier_gem_devil_left_hand:IsPurgable()
    return false -- 无法驱散
end
 
function modifier_gem_devil_left_hand:RemoveOnDeath()
    return false -- 死亡不移除
end

function modifier_gem_devil_left_hand:GetTexture()
    return "baowu/devil_left_hand"
end