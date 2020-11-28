if modifier_abyss_jianshang == nil then
	modifier_abyss_jianshang = class({})
end

function modifier_abyss_jianshang:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
    }
    return funcs
end

function modifier_abyss_jianshang:IsHidden()
	return false
end

function modifier_abyss_jianshang:GetModifierIncomingDamage_Percentage( params )
	return -98
end

function modifier_abyss_jianshang:IsPurgable()
    return false -- 无法驱散
end
 
function modifier_abyss_jianshang:RemoveOnDeath()
    return true -- 死亡移除
end

function modifier_abyss_jianshang:GetTexture()
    return "rubick_arcane_supremacy"
end