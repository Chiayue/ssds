-- 护甲神力 攻击10%概率造成护甲*护甲*等级*5%的魔法伤害 modifier_gem_look_my_armor

if modifier_gem_look_my_armor == nil then
	modifier_gem_look_my_armor = class({})
end

function modifier_gem_look_my_armor:IsHidden()
    if self:GetParent():HasModifier("modifier_gem_look_my_armor_OnAttackLanded") then 
        return true
    else
        return false
    end
end

function modifier_gem_look_my_armor:OnCreated(params)
    if not IsServer() then return end
    self:StartIntervalThink(1)
end

function modifier_gem_look_my_armor:OnIntervalThink(params)
    if not IsServer() then return end
    local hParent = self:GetParent()
    if hParent:HasModifier("modifier_gem_hujia_taozhuang") and not hParent:HasModifier("modifier_gem_look_my_armor_OnAttackLanded") then 
        hParent:AddNewModifier(hParent, self:GetAbility(), "modifier_gem_look_my_armor_OnAttackLanded", {})
        self:StartIntervalThink(-1)
    end
end

function modifier_gem_look_my_armor:IsPurgable()
    return false -- 无法驱散
end
 
function modifier_gem_look_my_armor:RemoveOnDeath()
    return false -- 死亡不移除
end

function modifier_gem_look_my_armor:GetTexture()
    return "hujiashengli"
end

function modifier_gem_look_my_armor:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
    }
    return funcs
end

function modifier_gem_look_my_armor:GetModifierPhysicalArmorBonus()
    return 50
end