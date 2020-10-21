if modifier_gem_emoqiyue == nil then
	modifier_gem_emoqiyue = class({})
end

function modifier_gem_emoqiyue:DeclareFunctions()
    local funcs = {
        
    }
    return funcs
end

function modifier_gem_emoqiyue:IsHidden()
	return false
end

function modifier_gem_emoqiyue:OnCreated(params)
    if IsServer() then
        local nCaster = self:GetParent()
        local PlayerID = nCaster:GetOwner():GetPlayerID()
        Player_Data:AddPoint(PlayerID,12000)
    end

    self:StartIntervalThink(1)
end

function modifier_gem_emoqiyue:OnIntervalThink()
    if IsServer() then
        local nCaster = self:GetParent()
        local nPlayerID = nCaster:GetOwner():GetPlayerID()
        local woods = Player_Data:getPoints(nPlayerID)
        if woods>30 then
            Player_Data:AddPoint(nPlayerID,-30)
        end
    end
    
	self:StartIntervalThink(1)
end

function modifier_gem_emoqiyue:IsPurgable()
    return false -- 无法驱散
end
 
function modifier_gem_emoqiyue:RemoveOnDeath()
    return false -- 死亡不移除
end

function modifier_gem_emoqiyue:GetTexture()
    return "baowu/emoqiyue"
end