if modifier_gem_power_of_aeolus == nil then
	modifier_gem_power_of_aeolus = class({})
end

function modifier_gem_power_of_aeolus:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
    }
    return funcs
end

function modifier_gem_power_of_aeolus:IsHidden()
	return false
end

function modifier_gem_power_of_aeolus:OnCreated(params)
    self.suit_attackspeed_add =  40
end

function modifier_gem_power_of_aeolus:GetModifierAttackSpeedBonus_Constant()
    return self.suit_attackspeed_add
end


function modifier_gem_power_of_aeolus:IsPurgable()
    return false -- 无法驱散
end
 
function modifier_gem_power_of_aeolus:RemoveOnDeath()
    return false -- 死亡不移除
end

function modifier_gem_power_of_aeolus:GetTexture()
    return "baowu/sk12"
end
