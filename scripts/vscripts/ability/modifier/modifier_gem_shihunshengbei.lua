if modifier_gem_shihunshengbei == nil then
	modifier_gem_shihunshengbei = class({})
end

function modifier_gem_shihunshengbei:DeclareFunctions()
    local funcs = {

    }
    return funcs
end

function modifier_gem_shihunshengbei:IsHidden()
	return false
end

function modifier_gem_shihunshengbei:OnCreated(params)
    
end

function modifier_gem_shihunshengbei:IsPurgable()
    return false -- 无法驱散
end
 
function modifier_gem_shihunshengbei:RemoveOnDeath()
    return false -- 死亡不移除
end

function modifier_gem_shihunshengbei:GetTexture()
    return "baowu/shihunshengbei"
end