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
    if self:GetCaster():HasModifier( "modifier_gem_hujia_taozhuang" ) then
        return true
    else
        return false
    end
end

function modifier_gem_platemail:OnCreated(params)
    self.armor_add = 10

    if IsServer() then
        local hero = self:GetParent()
        if hero:HasModifier("modifier_gem_chainmail") and hero:HasModifier("modifier_gem_bubaizhidun") and not hero:HasModifier("modifier_gem_hujia_taozhuang") then
            hero:AddNewModifier( hero, self:GetAbility(), "modifier_gem_hujia_taozhuang", {} )
        end
    end
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