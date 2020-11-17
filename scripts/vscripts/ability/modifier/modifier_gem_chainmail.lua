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
    if self:GetCaster():HasModifier( "modifier_gem_hujia_taozhuang" ) then
        return true
    else
        return false
    end
end

function modifier_gem_chainmail:OnCreated(params)
    self.armor_add = 5

    if IsServer() then
        local hero = self:GetParent()
        if hero:HasModifier("modifier_gem_platemail") and hero:HasModifier("modifier_gem_bubaizhidun") and not hero:HasModifier("modifier_gem_hujia_taozhuang") then
            hero:AddNewModifier( hero, self:GetAbility(), "modifier_gem_hujia_taozhuang", {} )
        end
    end
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