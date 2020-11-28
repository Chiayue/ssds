--解锁贪婪面具II  modifier_gem_greed_mask_true_OnAttackLanded

if modifier_gem_greed_mask_true_OnAttackLanded == nil then
	modifier_gem_greed_mask_true_OnAttackLanded = class({})
end

function modifier_gem_greed_mask_true_OnAttackLanded:IsHidden()
    if self:GetParent().gem_tanlanmianju == false then 
        return true 
    else
        return false
    end
end

function modifier_gem_greed_mask_true_OnAttackLanded:OnCreated(params)

end

function modifier_gem_greed_mask_true_OnAttackLanded:IsPurgable()
    return false -- 无法驱散
end
 
function modifier_gem_greed_mask_true_OnAttackLanded:RemoveOnDeath()
    return false -- 死亡不移除
end

function modifier_gem_greed_mask_true_OnAttackLanded:GetTexture()
    return "tanlanmianju-zhen"
end

function modifier_gem_greed_mask_true_OnAttackLanded:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_ATTACK_LANDED,
    }
    return funcs
end

function modifier_gem_greed_mask_true_OnAttackLanded:OnAttackLanded(params)
    if params.attacker ~= self:GetParent() then
		return 0
	end

	local hParent = self:GetParent()
    local hTarget = params.target

    local hPlayerID = hParent:GetOwner():GetPlayerID()
    local woods = Player_Data:getPoints(hPlayerID)
    if woods>0 then
        if hParent.gem_tanlanmianju == false then 
            Player_Data:AddPoint(hPlayerID,10)
        else 
            Player_Data:AddPoint(hPlayerID,15)
        end
    end
end