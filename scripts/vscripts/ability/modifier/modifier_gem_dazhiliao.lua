if modifier_gem_dazhiliao == nil then
	modifier_gem_dazhiliao = class({})
end

function modifier_gem_dazhiliao:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE ,
    }
    return funcs
end

function modifier_gem_dazhiliao:IsHidden()
	return false
end

function modifier_gem_dazhiliao:OnCreated(params)
    self.health_regen = 1.5
end

function modifier_gem_dazhiliao:GetModifierHealthRegenPercentage()
    return self.health_regen
end

function modifier_gem_dazhiliao:IsPurgable()
    return false -- 无法驱散
end
 
function modifier_gem_dazhiliao:RemoveOnDeath()
    return false -- 死亡不移除
end

function modifier_gem_dazhiliao:GetTexture()
    return "baowu/dazhiliao"
end