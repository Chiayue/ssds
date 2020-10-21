if modifier_gem_xunjizhijian_lua == nil then
	modifier_gem_xunjizhijian_lua = class({})
end

function modifier_gem_xunjizhijian_lua:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,
    }
    return funcs
end

function modifier_gem_xunjizhijian_lua:IsHidden()
	return false
end

function modifier_gem_xunjizhijian_lua:OnCreated( kv )
	self.damage_percent = 10
    self.attack_speed = 30
end

function modifier_gem_xunjizhijian_lua:GetModifierAttackSpeedBonus_Constant()
    -- 攻速变化
    return self.attack_speed
end

function modifier_gem_xunjizhijian_lua:GetModifierDamageOutgoing_Percentage()
    -- 攻击力变化
	return self.damage_percent
end

function modifier_gem_xunjizhijian_lua:IsPurgable()
    return false -- 无法驱散
end
 
function modifier_gem_xunjizhijian_lua:RemoveOnDeath()
    return false -- 死亡不移除
end

function modifier_gem_xunjizhijian_lua:GetTexture()
    return "baowu/gem_xunjizhijian_lua"
end