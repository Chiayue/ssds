-- 敏捷爆炸 当该宝物是你前五个选择的宝物，敏捷+100% modifier_gem_agility_explode

if modifier_gem_agility_explode == nil then
	modifier_gem_agility_explode = class({})
end

function modifier_gem_agility_explode:IsHidden()
    return true
end

function modifier_gem_agility_explode:OnCreated(params)
    if not IsServer() then return end 
    local hParent = self:GetParent()
    local nPlayerID = hParent:GetOwner():GetPlayerID()
    local devil_list_count = GlobalVarFunc.devilNameCount[nPlayerID + 1]
    --DeepPrintTable(GlobalVarFunc.devilNameCount[nPlayerID + 1])
    if #devil_list_count <= 6 then 
        hParent:AddNewModifier(hParent, self:GetAbility(), "modifier_gem_agility_explode_additional", {})
        hParent:RemoveModifierByName("modifier_gem_agility_explode")
    else
        hParent:RemoveModifierByName("modifier_gem_agility_explode")
    end
end

function modifier_gem_agility_explode:IsPurgable()
    return false -- 无法驱散
end
 
function modifier_gem_agility_explode:RemoveOnDeath()
    return false -- 死亡不移除
end

function modifier_gem_agility_explode:GetTexture()
    return "mingjiebaozha"
end