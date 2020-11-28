if modifier_gem_tanlan == nil then
	modifier_gem_tanlan = class({})
end

function modifier_gem_tanlan:DeclareFunctions()
    local funcs = {
    }
    return funcs
end

function modifier_gem_tanlan:IsHidden()
	return false
end

function modifier_gem_tanlan:OnCreated(params)
end

function modifier_gem_tanlan:IsPurgable()
    return false -- 无法驱散
end
 
function modifier_gem_tanlan:RemoveOnDeath()
    return false -- 死亡不移除
end

function modifier_gem_tanlan:GetTexture()
    return "baowu/tanlan"
end