if modifier_gem_shuangren_fu == nil then
	modifier_gem_shuangren_fu = class({})
end

function modifier_gem_shuangren_fu:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
    }
    return funcs
end

function modifier_gem_shuangren_fu:IsHidden()
	return false
end

function modifier_gem_shuangren_fu:OnCreated(params)
    self.attack_add = 25
    self.attack_speed = 10
end

function modifier_gem_shuangren_fu:GetModifierDamageOutgoing_Percentage()
    return self.attack_add
end

function modifier_gem_shuangren_fu:GetModifierAttackSpeedBonus_Constant()
    return self.attack_speed
end

function modifier_gem_shuangren_fu:IsPurgable()
    return false -- 无法驱散
end
 
function modifier_gem_shuangren_fu:RemoveOnDeath()
    return false -- 死亡不移除
end

function modifier_gem_shuangren_fu:GetTexture(  )
    return "baowu/gem_shuangren_fu"
end
