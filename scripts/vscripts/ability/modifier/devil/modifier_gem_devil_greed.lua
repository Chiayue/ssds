-- 团队之手 贪婪CD-10%(乘算) 每次贪婪35%几率额外贪婪一次 modifier_gem_devil_greed

if modifier_gem_devil_greed == nil then
	modifier_gem_devil_greed = class({})
end

function modifier_gem_devil_greed:IsHidden()
    if self:GetParent():HasModifier("modifier_gem_devil_greed_additional") then 
        return true 
    else
        return false
    end
end

function modifier_gem_devil_greed:OnCreated(params)
    if not IsServer() then return end 
    self:StartIntervalThink(1)
    
    -- local nPlayerID = hParent:GetPlayerID()
    -- local hDuliu = Player_Data:GetStatusInfo(nPlayerID)
    -- local nInCooldown = hDuliu["duliu_in_cd"]
    -- hDuliu["duliu_in_cd"] = nInCooldown - nInCooldown * 0.1

    -- if hParent:HasModifier("modifier_gem_tanlan") then 
    
    --     local greed_nuber = CustomNetTables:GetTableValue( "gameInfo", "challenge" )
    --     for k, v in pairs(greed_nuber) do
    --         if tonumber(k) == nPlayerID then
    --             local chance = 100

    --             local nowChance = RandomInt(0,100)
    --             if nowChance  > chance then
    --                 return 0
    --             end
    --             v.DuLiuNum = v.DuLiuNum + 1
    --             CustomNetTables:SetTableValue( "gameInfo", "challenge", greed_nuber)
    --         end
    --     end
    -- end
end

function modifier_gem_devil_greed:OnIntervalThink()
    if not IsServer() then return end 
    local hParent = self:GetParent()
    if hParent:HasModifier("modifier_gem_tanlan") and not hParent:HasModifier("modifier_gem_devil_greed_additional") then
        hParent:AddNewModifier(hParent, self:GetAbility(), "modifier_gem_devil_greed_additional", {})
        self:StartIntervalThink(-1)
    end
end

function modifier_gem_devil_greed:IsPurgable()
    return false -- 无法驱散
end
 
function modifier_gem_devil_greed:RemoveOnDeath()
    return false -- 死亡不移除
end

function modifier_gem_devil_greed:GetTexture()
    return "tuanduizhishou"
end
