if modifier_gem_fuhuoshijian == nil then
	modifier_gem_fuhuoshijian = class({})
end

function modifier_gem_fuhuoshijian:IsHidden()
    return false
end

function modifier_gem_fuhuoshijian:OnCreated(params)
    if IsServer() then
        local nCaster = self:GetParent()
        local nPlayerID = nCaster:GetOwner():GetPlayerID()
        GlobalVarFunc.resurrectionTime[nPlayerID + 1] = 5
    end
end

function modifier_gem_fuhuoshijian:IsPurgable()
    return false -- 无法驱散
end
 
function modifier_gem_fuhuoshijian:RemoveOnDeath()
    return false -- 死亡不移除
end

function modifier_gem_fuhuoshijian:GetTexture(  )
    return "baowu/fuhuoshijian"
end