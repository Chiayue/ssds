if modifier_gem_tiangoubudehaosi == nil then
	modifier_gem_tiangoubudehaosi = class({})
end

function modifier_gem_tiangoubudehaosi:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_ATTACKED,
    }
    return funcs
end

function modifier_gem_tiangoubudehaosi:IsHidden()
	return false
end

function modifier_gem_tiangoubudehaosi:OnAttacked(args)
    local target = args.target
    if target:GetUnitName() == "npc_dota_gold_mine" then
        local nAttacker = args.attacker
        local nCaster = self:GetParent()
        if nAttacker == nCaster then

            local strength = nCaster:GetBaseStrength()
            nCaster:SetBaseStrength(strength+1) 

            local agility = nCaster:GetBaseAgility()
            nCaster:SetBaseAgility(agility+1) 
    
            local Intellect = nCaster:GetBaseIntellect()
            nCaster:SetBaseIntellect(Intellect+1)

        end
    end
end

function modifier_gem_tiangoubudehaosi:IsPurgable()
    return false -- 无法驱散
end
 
function modifier_gem_tiangoubudehaosi:RemoveOnDeath()
    return false -- 死亡不移除
end

function modifier_gem_tiangoubudehaosi:GetTexture()
    return "baowu/tiangoubudehaosi"
end