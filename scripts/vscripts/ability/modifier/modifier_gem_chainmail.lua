if modifier_gem_chainmail == nil then
	modifier_gem_chainmail = class({})
end

function modifier_gem_chainmail:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS ,
    }
    return funcs
end

function modifier_gem_chainmail:IsHidden()
	return false
end

function modifier_gem_chainmail:OnCreated(params)
    self.armor_add = 5
end

function modifier_gem_chainmail:GetModifierPhysicalArmorBonus()
    return self.armor_add
end

function modifier_gem_chainmail:IsPurgable()
    return false -- 无法驱散
end
 
function modifier_gem_chainmail:RemoveOnDeath()
    return false -- 死亡不移除
end

function modifier_gem_chainmail:GetTexture()
    return "baowu/gem_chainmail"
end