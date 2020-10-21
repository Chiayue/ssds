if modifier_gem_yinxuejian == nil then
	modifier_gem_yinxuejian = class({})
end

function modifier_gem_yinxuejian:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_DEATH,
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
    }
    return funcs
end

function modifier_gem_yinxuejian:IsHidden()
	return false
end

function modifier_gem_yinxuejian:OnCreated(params)
    self.attribute_promotion = 1000
    self.current_stack = 0
end

function modifier_gem_yinxuejian:OnDeath(args)
    local nAttacker = args.attacker
	local nCaster = self:GetParent()
    if nAttacker == nCaster then
        self.current_stack = self.current_stack + 1
        nCaster:SetModifierStackCount( "modifier_gem_yinxuejian", nCaster, self.current_stack )
	end
end

--力量
function modifier_gem_yinxuejian:GetModifierBonusStats_Strength()
    if self:GetParent():GetModifierStackCount( "modifier_gem_yinxuejian" , nil ) >= 1250 then
        return self.attribute_promotion
    end
end

--智力
function modifier_gem_yinxuejian:GetModifierBonusStats_Intellect()
    if self:GetParent():GetModifierStackCount( "modifier_gem_yinxuejian" , nil ) >= 1250 then
        return self.attribute_promotion
    end
end

--敏捷
function modifier_gem_yinxuejian:GetModifierBonusStats_Agility()
    if self:GetParent():GetModifierStackCount( "modifier_gem_yinxuejian" , nil ) >= 1250 then
        return self.attribute_promotion
    end
end

function modifier_gem_yinxuejian:IsPurgable()
    return false -- 无法驱散
end
 
function modifier_gem_yinxuejian:RemoveOnDeath()
    return false -- 死亡不移除
end

function modifier_gem_yinxuejian:GetTexture(  )
    return "baowu/yinxuejian"
end
