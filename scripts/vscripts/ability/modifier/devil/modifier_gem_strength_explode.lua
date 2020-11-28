-- 力量爆炸 当该宝物是你前五个选择的宝物，力量+100% modifier_gem_strength_explode

if modifier_gem_strength_explode == nil then
	modifier_gem_strength_explode = class({})
end

function modifier_gem_strength_explode:IsHidden()
    return true
end

function modifier_gem_strength_explode:OnCreated(params)
    if not IsServer() then return end 
    local hParent = self:GetParent()
    local nPlayerID = hParent:GetOwner():GetPlayerID()
    local devil_list_count = GlobalVarFunc.devilNameCount[nPlayerID + 1]
    -- DeepPrintTable(devil_list_count)
    -- print("count>>>>>>>=",#devil_list_count)
    if #devil_list_count <= 6 then 
        hParent:AddNewModifier(hParent, self:GetAbility(), "modifier_gem_strength_explode_additional", {})
        hParent:RemoveModifierByName("modifier_gem_strength_explode")
    else
        hParent:RemoveModifierByName("modifier_gem_strength_explode")
    end
end

function modifier_gem_strength_explode:IsPurgable()
    return false -- 无法驱散
end
 
function modifier_gem_strength_explode:RemoveOnDeath()
    return false -- 死亡不移除
end

function modifier_gem_strength_explode:GetTexture()
    return "liliangbaozha"
end