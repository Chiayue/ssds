if modifier_gem_zuanshi_touzi == nil then
	modifier_gem_zuanshi_touzi = class({})
end

function modifier_gem_zuanshi_touzi:DeclareFunctions()
    local funcs = {
    }
    return funcs
end

function modifier_gem_zuanshi_touzi:IsHidden()
    return false
end

function modifier_gem_zuanshi_touzi:OnCreated(params)
end

function modifier_gem_zuanshi_touzi:IsPurgable()
    return false -- 无法驱散
end
 
function modifier_gem_zuanshi_touzi:RemoveOnDeath()
    return false -- 死亡不移除
end

function modifier_gem_zuanshi_touzi:GetTexture()
    return "baowu/zuanshitouzi"
end