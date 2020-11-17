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
    if self:GetCaster():HasModifier( "modifier_gem_hujia_taozhuang" ) then
        return true
    else
        return false
    end
end

function modifier_gem_bubaizhidun:OnCreated(params)
    self.armor_add = 30
    self.attackspeed_add = -100

    if IsServer() then
        local hero = self:GetParent()
        if hero:HasModifier("modifier_gem_chainmail") and hero:HasModifier("modifier_gem_platemail") and not hero:HasModifier("modifier_gem_hujia_taozhuang") then
            hero:AddNewModifier( hero, self:GetAbility(), "modifier_gem_hujia_taozhuang", {} )
        end
    end
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