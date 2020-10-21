if modifier_gem_bubaizhidun == nil then
	modifier_gem_bubaizhidun = class({})
end

function modifier_gem_bubaizhidun:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS ,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
    }
    return funcs
end

function modifier_gem_bubaizhidun:IsHidden()
	return false
end

function modifier_gem_bubaizhidun:OnCreated(params)
    self.armor_add = 30
    self.attackspeed_add = -100
end

function modifier_gem_bubaizhidun:GetModifierPhysicalArmorBonus()
    return self.armor_add
end

function modifier_gem_bubaizhidun:GetModifierAttackSpeedBonus_Constant()
    return self.attackspeed_add
end

function modifier_gem_bubaizhidun:IsPurgable()
    return false -- 无法驱散
end
 
function modifier_gem_bubaizhidun:RemoveOnDeath()
    return false -- 死亡不移除
end

function modifier_gem_bubaizhidun:GetTexture()
    return "baowu/bubaizhidun"
end