if modifier_gem_bow_of_aeolus == nil then
	modifier_gem_bow_of_aeolus = class({})
end

function modifier_gem_bow_of_aeolus:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
    }
    return funcs
end

function modifier_gem_bow_of_aeolus:IsHidden()
	if self:GetCaster():HasModifier( "modifier_gem_power_of_aeolus" ) then
        return true
    else
        return false
    end
end

function modifier_gem_bow_of_aeolus:OnCreated(params)
    if IsServer() then 
        local hero = self:GetParent()
        if hero:HasModifier("modifier_gem_arrow_of_aeolus") and not hero:HasModifier("modifier_gem_power_of_aeolus") then
            hero:AddNewModifier( hero, nil, "modifier_gem_power_of_aeolus", {} )
        end
    end
end

function modifier_gem_bow_of_aeolus:IsPurgable()
    return false -- 无法驱散
end
 
function modifier_gem_bow_of_aeolus:RemoveOnDeath()
    return false -- 死亡不移除
end

function modifier_gem_bow_of_aeolus:GetTexture()
    return "baowu/gem_bow_of_aeolus"
end
