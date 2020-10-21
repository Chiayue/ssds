if modifier_gem_huiguang_fu == nil then
	modifier_gem_huiguang_fu = class({})
end

function modifier_gem_huiguang_fu:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE ,
    }
    return funcs
end

function modifier_gem_huiguang_fu:IsHidden()
	return false
end

function modifier_gem_huiguang_fu:OnCreated(params)
    self.attack_add = 40
end

function modifier_gem_huiguang_fu:GetModifierDamageOutgoing_Percentage ()
    return self.attack_add
end

function modifier_gem_huiguang_fu:IsPurgable()
    return false -- 无法驱散
end
 
function modifier_gem_huiguang_fu:RemoveOnDeath()
    return false -- 死亡不移除
end

function modifier_gem_huiguang_fu:GetTexture()
    return "baowu/gem_huiguang_fu"
end