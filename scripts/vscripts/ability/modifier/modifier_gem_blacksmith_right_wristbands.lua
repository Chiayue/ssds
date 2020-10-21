if modifier_gem_blacksmith_right_wristbands == nil then
	modifier_gem_blacksmith_right_wristbands = class({})
end

function modifier_gem_blacksmith_right_wristbands:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_HEALTH_BONUS,
    }
    return funcs
end

function modifier_gem_blacksmith_right_wristbands:IsHidden()
	if self:GetCaster():HasModifier( "modifier_gem_blacksmith_power" ) then
        return true
    else
        return false
    end
end

function modifier_gem_blacksmith_right_wristbands:OnCreated(params)
	if IsServer() then
        local hero = self:GetParent()
        if hero:HasModifier("modifier_gem_blacksmith_left_wristbands") and not hero:HasModifier("modifier_gem_blacksmith_power") then
            hero:AddNewModifier( hero, nil, "modifier_gem_blacksmith_power", {} )
        end
    end
end

function modifier_gem_blacksmith_right_wristbands:IsPurgable()
    return false -- 无法驱散
end
 
function modifier_gem_blacksmith_right_wristbands:RemoveOnDeath()
    return false -- 死亡不移除
end

function modifier_gem_blacksmith_right_wristbands:GetTexture()
    return "baowu/gem_blacksmith_right_wristbands"
end