if modifier_gem_tanlanmianju == nil then
	modifier_gem_tanlanmianju = class({})
end

function modifier_gem_tanlanmianju:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_ATTACKED ,
    }
    return funcs
end

function modifier_gem_tanlanmianju:IsHidden()
	return false
end

function modifier_gem_tanlanmianju:OnCreated(params)
    self:StartIntervalThink(1)
end

function modifier_gem_tanlanmianju:OnIntervalThink()
    if IsServer() then
        local nCaster = self:GetParent()
        local PlayerID = nCaster:GetOwner():GetPlayerID()
        local gold = PlayerResource:GetGold(PlayerID)
        if gold > -100000 then
            PlayerResource:SpendGold(PlayerID,50,DOTA_ModifyGold_AbilityCost)
        end
    end
    
	self:StartIntervalThink(1)
end

function modifier_gem_tanlanmianju:OnAttacked(args)
    local nAttacker = args.attacker
	local nCaster = self:GetParent()
    if nAttacker == nCaster then
        local PlayerID = nAttacker:GetOwner():GetPlayerID()
        if GlobalVarFunc.MonsterWave > 30 then
            PlayerResource:ModifyGold(PlayerID,6,true,DOTA_ModifyGold_Unspecified)
            PopupGoldGain(nAttacker, 6)
        else
            PlayerResource:ModifyGold(PlayerID,12,true,DOTA_ModifyGold_Unspecified)
            PopupGoldGain(nAttacker, 12)
        end
    end
end

function modifier_gem_tanlanmianju:IsPurgable()
    return false -- 无法驱散
end
 
function modifier_gem_tanlanmianju:RemoveOnDeath()
    return false -- 死亡不移除
end

function modifier_gem_tanlanmianju:GetTexture()
    return "baowu/mianju"
end