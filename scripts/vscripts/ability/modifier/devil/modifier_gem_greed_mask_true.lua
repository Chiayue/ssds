-- 贪婪面具II 拥有贪婪面具:移除贪婪面具每秒-50金币负面效果，每次攻击木材+15 modifier_gem_greed_mask_true

if modifier_gem_greed_mask_true == nil then
	modifier_gem_greed_mask_true = class({})
end

function modifier_gem_greed_mask_true:IsHidden()
    if self:GetParent().gem_tanlanmianju == false then 
        return false
    else
        return true
    end
end

function modifier_gem_greed_mask_true:OnCreated(params)
    
    if IsServer() then
        local hParent = self:GetParent()
        hParent.gem_tanlanmianju = false
        local PlayerID = hParent:GetOwner():GetPlayerID()
        Player_Data:AddPoint(PlayerID,100000)
        hParent:AddNewModifier(hParent, self:GetAbility(), "modifier_gem_greed_mask_true_OnAttackLanded", {})
        self:StartIntervalThink(1)
    end
end

function modifier_gem_greed_mask_true:OnIntervalThink()
    if not IsServer() then return end
    local hParent = self:GetParent()
    if hParent:HasModifier("modifier_gem_tanlanmianju") then 
        hParent.gem_tanlanmianju = true
        hParent:RemoveModifierByName("modifier_gem_tanlanmianju")
        self:StartIntervalThink(-1)
    end
end

function modifier_gem_greed_mask_true:IsPurgable()
    return false -- 无法驱散
end
 
function modifier_gem_greed_mask_true:RemoveOnDeath()
    return false -- 死亡不移除
end

function modifier_gem_greed_mask_true:GetTexture()
    return "tanlanmianju"
end