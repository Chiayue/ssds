if modifier_gem_yuanshemoshi == nil then
	modifier_gem_yuanshemoshi = class({})
end

function modifier_gem_yuanshemoshi:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT, -- 移动速度
        MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
    }
    return funcs
end

function modifier_gem_yuanshemoshi:IsHidden()
	return false
end

function modifier_gem_yuanshemoshi:OnCreated(params)
    self.move_speed_add = -100
    self.range_bonus = 400
end

--移动速度
function modifier_gem_yuanshemoshi:GetModifierMoveSpeedBonus_Constant ()
    return self.move_speed_add
end

--射程
function modifier_gem_yuanshemoshi:GetModifierAttackRangeBonus()
	return self.range_bonus
end

function modifier_gem_yuanshemoshi:IsPurgable()
    return false -- 无法驱散
end
 
function modifier_gem_yuanshemoshi:RemoveOnDeath()
    return false -- 死亡不移除
end

function modifier_gem_yuanshemoshi:GetTexture()
    return "baowu/yuanshemoshi"
end