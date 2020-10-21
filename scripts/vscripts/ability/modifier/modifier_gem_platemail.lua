if modifier_gem_platemail == nil then
	modifier_gem_platemail = class({})
end

function modifier_gem_platemail:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS ,
    }
    return funcs
end

function modifier_gem_platemail:IsHidden()
	return false
end

function modifier_gem_platemail:OnCreated(params)
    self.armor_add = 10
end

function modifier_gem_platemail:GetModifierPhysicalArmorBonus()
    return self.armor_add
end

function modifier_gem_platemail:IsPurgable()
    return false -- 无法驱散
end
 
function modifier_gem_platemail:RemoveOnDeath()
    return false -- 死亡不移除
end

function modifier_gem_platemail:GetTexture()
    return "baowu/gem_platemail"
end