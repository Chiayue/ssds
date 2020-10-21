if modifier_gem_shixue_lua == nil then
	modifier_gem_shixue_lua = class({})
end

function modifier_gem_shixue_lua:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
    }
    return funcs
end

function modifier_gem_shixue_lua:IsHidden()
	return false
end

function modifier_gem_shixue_lua:OnCreated( kv )
	self.attack_speed = 50 
end

function modifier_gem_shixue_lua:GetModifierAttackSpeedBonus_Constant()
    -- 攻速变化
    return self.attack_speed
end

function modifier_gem_shixue_lua:IsPurgable()
    return false -- 无法驱散
end
 
function modifier_gem_shixue_lua:RemoveOnDeath()
    return false -- 死亡不移除
end

function modifier_gem_shixue_lua:GetTexture()
    return "baowu/gem_shixue_lua"
end