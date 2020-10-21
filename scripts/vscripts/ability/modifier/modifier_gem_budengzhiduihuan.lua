if modifier_gem_budengzhiduihuan == nil then
	modifier_gem_budengzhiduihuan = class({})
end

function modifier_gem_budengzhiduihuan:DeclareFunctions()
    local funcs = {
        
    }
    return funcs
end

function modifier_gem_budengzhiduihuan:IsHidden()
	return false
end

function modifier_gem_budengzhiduihuan:OnCreated(params)
    self:StartIntervalThink(1)
end

function modifier_gem_budengzhiduihuan:OnIntervalThink()
    
    if IsServer() then
        local nCaster = self:GetParent()
        local PlayerID = nCaster:GetOwner():GetPlayerID()
        local gold = PlayerResource:GetGold(PlayerID)
        if gold >= 90000 then
            PlayerResource:SpendGold(PlayerID,90000,DOTA_ModifyGold_AbilityCost)
            Player_Data:AddPoint(PlayerID,12000)
        end
    end
    
	self:StartIntervalThink(1)
end

function modifier_gem_budengzhiduihuan:IsPurgable()
    return false -- 无法驱散
end
 
function modifier_gem_budengzhiduihuan:RemoveOnDeath()
    return false -- 死亡不移除
end

function modifier_gem_budengzhiduihuan:GetTexture()
    return "baowu/budengzhiduihuan"
end