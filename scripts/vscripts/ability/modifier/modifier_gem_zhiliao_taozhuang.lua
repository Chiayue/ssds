if modifier_gem_zhiliao_taozhuang == nil then
	modifier_gem_zhiliao_taozhuang = class({})
end

function modifier_gem_zhiliao_taozhuang:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
    }
    return funcs
end

function modifier_gem_zhiliao_taozhuang:IsHidden()
	return false
end

function modifier_gem_zhiliao_taozhuang:GetModifierIncomingDamage_Percentage( params )
	return -5
end

function modifier_gem_zhiliao_taozhuang:IsPurgable()
    return false -- 无法驱散
end
 
function modifier_gem_zhiliao_taozhuang:RemoveOnDeath()
    return false -- 死亡不移除
end

function modifier_gem_zhiliao_taozhuang:GetTexture()
    return "baowu/zhiliao_taozhuang"
end