-- 法神领悟 凑齐BUFF套:10%概率对敌方造成自身全属性*个人等级*25%的魔法伤害 清除套装CD  modifier_gem_special_suit_buff

if modifier_gem_special_suit_buff == nil then
	modifier_gem_special_suit_buff = class({})
end

function modifier_gem_special_suit_buff:IsHidden()
    if self:GetParent():HasModifier("modifier_gem_special_suit_buff_OnAttackLanded") then
        return true
    else
        return false
    end
end

function modifier_gem_special_suit_buff:OnCreated(params)
    if not IsServer() then return end
    self:StartIntervalThink(1)
end

function modifier_gem_special_suit_buff:OnIntervalThink(params)
    if not IsServer() then return end
    local hParent = self:GetParent()
    if hParent:HasModifier("modifier_gem_special_buff") and not hParent:HasModifier("modifier_gem_special_suit_buff_OnAttackLanded") then 
        hParent:AddNewModifier(hParent, self:GetAbility(), "modifier_gem_special_suit_buff_OnAttackLanded", {})
        self:StartIntervalThink(-1)
    end
end

function modifier_gem_special_suit_buff:IsPurgable()
    return false -- 无法驱散
end
 
function modifier_gem_special_suit_buff:RemoveOnDeath()
    return false -- 死亡不移除
end

function modifier_gem_special_suit_buff:GetTexture()
    return "fashenlingwu"
end