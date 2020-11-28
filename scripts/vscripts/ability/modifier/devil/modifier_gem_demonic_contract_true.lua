-- 恶魔契约II 拥有恶魔契约:移除恶魔契约每秒-30木材负面效果，每秒木材+150，同时一次性给予10万木材 modifier_gem_demonic_contract_true

if modifier_gem_demonic_contract_true == nil then
	modifier_gem_demonic_contract_true = class({})
end

function modifier_gem_demonic_contract_true:IsHidden()
    return false
end

function modifier_gem_demonic_contract_true:OnCreated(params)
    if IsServer() then   
        self:StartIntervalThink(1)
    end
end

function modifier_gem_demonic_contract_true:OnIntervalThink()
    if IsServer() then
        local hParent = self:GetParent()
        local hPlayerID = hParent:GetOwner():GetPlayerID()
        local woods = Player_Data:getPoints(hPlayerID)
        if woods>0 then
            Player_Data:AddPoint(hPlayerID,100)
        end

        if hParent:HasModifier("modifier_gem_emoqiyue") and not hParent:HasModifier("modifier_gem_memnoch_the_devil_true") then 
            hParent:AddNewModifier(hParent, self:GetAbility(), "modifier_gem_memnoch_the_devil_true", {})
            hParent:RemoveModifierByName("modifier_gem_emoqiyue")
            hParent:RemoveModifierByName("modifier_gem_demonic_contract_true")
        end
    end
end

function modifier_gem_demonic_contract_true:IsPurgable()
    return false -- 无法驱散
end
 
function modifier_gem_demonic_contract_true:RemoveOnDeath()
    return false -- 死亡不移除
end

function modifier_gem_demonic_contract_true:GetTexture()
    return "emoqiyueII"
end