if modifier_gem_god_right_hand == nil then
	modifier_gem_god_right_hand = class({})
end

function modifier_gem_god_right_hand:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,
    }
    return funcs
end

function modifier_gem_god_right_hand:IsHidden()
	if self:GetCaster():HasModifier( "modifier_gem_god_hand" ) then
        return true
    else
        return false
    end
end

function modifier_gem_god_right_hand:OnCreated(params)
    self.damage_percent = 20
    if IsServer() then
        local hero = self:GetParent()
        if hero:HasModifier("modifier_gem_god_left_hand") and not hero:HasModifier("modifier_gem_god_hand") then
            hero:AddNewModifier( hero, nil, "modifier_gem_god_hand", {} )
        end
    end
    
end

function modifier_gem_god_right_hand:GetModifierDamageOutgoing_Percentage()
    return self.damage_percent
end

function modifier_gem_god_right_hand:IsPurgable()
    return false -- 无法驱散
end
 
function modifier_gem_god_right_hand:RemoveOnDeath()
    return false -- 死亡不移除
end

function modifier_gem_god_right_hand:GetTexture(  )
    return "baowu/gem_god_right_hand"
end
