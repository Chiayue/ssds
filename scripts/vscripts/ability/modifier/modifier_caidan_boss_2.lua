if modifier_caidan_boss_2 == nil then
	modifier_caidan_boss_2 = class({})
end

function modifier_caidan_boss_2:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
    }
    return funcs
end

function modifier_caidan_boss_2:IsHidden()
	return true
end

function modifier_caidan_boss_2:OnCreated(params)
end

--力量
function modifier_caidan_boss_2:GetModifierBonusStats_Strength()
    return GlobalVarFunc.baoWuShuSuiPian * 800
end

--智力
function modifier_caidan_boss_2:GetModifierBonusStats_Intellect()
    return GlobalVarFunc.baoWuShuSuiPian * 800
end

--敏捷
function modifier_caidan_boss_2:GetModifierBonusStats_Agility()
    return GlobalVarFunc.baoWuShuSuiPian * 800
end

function modifier_caidan_boss_2:IsPurgable()
    return false -- 无法驱散
end
 
function modifier_caidan_boss_2:RemoveOnDeath()
    return false -- 死亡不移除
end

function modifier_caidan_boss_2:GetTexture(  )
    return "baowu/yinxuejian"
end
