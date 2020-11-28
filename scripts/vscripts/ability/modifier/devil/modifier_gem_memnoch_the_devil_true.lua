-- 恶魔契约【真】 modifier_gem_memnoch_the_devil_true

if modifier_gem_memnoch_the_devil_true == nil then
	modifier_gem_memnoch_the_devil_true = class({})
end

function modifier_gem_memnoch_the_devil_true:IsHidden()
    return false
end

function modifier_gem_memnoch_the_devil_true:OnCreated(params)
    if IsServer() then
        self.gem_emoqiyue = false
        self.modifier_gem_emoqiyue = false
        local hParent = self:GetParent()
        local PlayerID = hParent:GetOwner():GetPlayerID()
        Player_Data:AddPoint(PlayerID,100000)

        self:StartIntervalThink(1)
    end
end

function modifier_gem_memnoch_the_devil_true:OnIntervalThink()
    if IsServer() then
        local hParent = self:GetParent()
        local hPlayerID = hParent:GetOwner():GetPlayerID()
        local woods = Player_Data:getPoints(hPlayerID)
        if woods>0 then
            Player_Data:AddPoint(hPlayerID,150)
        end
    end
end

function modifier_gem_memnoch_the_devil_true:IsPurgable()
    return false -- 无法驱散
end
 
function modifier_gem_memnoch_the_devil_true:RemoveOnDeath()
    return false -- 死亡不移除
end

function modifier_gem_memnoch_the_devil_true:GetTexture()
    return "emoqiyue-zhen"
end