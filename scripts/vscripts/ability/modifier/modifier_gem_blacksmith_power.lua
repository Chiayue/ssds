if modifier_gem_blacksmith_power == nil then
	modifier_gem_blacksmith_power = class({})
end

function modifier_gem_blacksmith_power:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
        MODIFIER_PROPERTY_HEALTH_BONUS,
    }
    return funcs
end

function modifier_gem_blacksmith_power:IsHidden()
	return false
end

function modifier_gem_blacksmith_power:OnCreated(params)
end

function modifier_gem_blacksmith_power:IsPurgable()
    return false -- 无法驱散
end
 
function modifier_gem_blacksmith_power:RemoveOnDeath()
    return false -- 死亡不移除
end

function modifier_gem_blacksmith_power:GetTexture()
    return "baowu/gem_break_then_set_lua"
end
