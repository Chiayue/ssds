if modifier_caidan_boss == nil then
	modifier_caidan_boss = class({})
end

function modifier_caidan_boss:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
    }
    return funcs
end

function modifier_caidan_boss:IsHidden()
	return true
end

function modifier_caidan_boss:OnCreated(params)
end

--力量
function modifier_caidan_boss:GetModifierBonusStats_Strength()
    return 1000
end

--智力
function modifier_caidan_boss:GetModifierBonusStats_Intellect()
    return 1000
end

--敏捷
function modifier_caidan_boss:GetModifierBonusStats_Agility()
    return 1000
end

function modifier_caidan_boss:IsPurgable()
    return false -- 无法驱散
end
 
function modifier_caidan_boss:RemoveOnDeath()
    return false -- 死亡不移除
end

function modifier_caidan_boss:GetTexture(  )
    return "baowu/yinxuejian"
end
