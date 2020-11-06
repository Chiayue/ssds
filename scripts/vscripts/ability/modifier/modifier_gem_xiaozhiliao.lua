if modifier_gem_xiaozhiliao == nil then
	modifier_gem_xiaozhiliao = class({})
end

function modifier_gem_xiaozhiliao:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE ,
    }
    return funcs
end

function modifier_gem_xiaozhiliao:IsHidden()
	return false
end

function modifier_gem_xiaozhiliao:OnCreated(params)
    self.health_regen = 0.5
end

function modifier_gem_xiaozhiliao:GetModifierHealthRegenPercentage()
    return self.health_regen
end

function modifier_gem_xiaozhiliao:IsPurgable()
    return false -- 无法驱散
end
 
function modifier_gem_xiaozhiliao:RemoveOnDeath()
    return false -- 死亡不移除
end

function modifier_gem_xiaozhiliao:GetTexture()
    return "baowu/xiaozhiliao"
end