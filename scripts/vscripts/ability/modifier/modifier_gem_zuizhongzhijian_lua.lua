if modifier_gem_zuizhongzhijian_lua == nil then
	modifier_gem_zuizhongzhijian_lua = class({})
end

function modifier_gem_zuizhongzhijian_lua:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,
    }
    return funcs
end

function modifier_gem_zuizhongzhijian_lua:IsHidden()
	return false
end

function modifier_gem_zuizhongzhijian_lua:OnCreated( kv )
	self.damage_percent = 30
end

function modifier_gem_zuizhongzhijian_lua:GetModifierDamageOutgoing_Percentage()
    -- 攻击力变化
	return self.damage_percent
end

function modifier_gem_zuizhongzhijian_lua:IsPurgable()
    return false -- 无法驱散
end
 
function modifier_gem_zuizhongzhijian_lua:RemoveOnDeath()
    return false -- 死亡不移除
end

function modifier_gem_zuizhongzhijian_lua:GetTexture()
    return "baowu/gem_zuizhongzhijian_lua"
end