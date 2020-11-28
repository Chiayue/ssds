if modifier_gem_huihedashang == nil then
	modifier_gem_huihedashang = class({})
end

function modifier_gem_huihedashang:DeclareFunctions()
    local funcs = {
    }
    return funcs
end

function modifier_gem_huihedashang:IsHidden()
    return false
end

function modifier_gem_huihedashang:OnCreated(params)
end

function modifier_gem_huihedashang:IsPurgable()
    return false -- 无法驱散
end
 
function modifier_gem_huihedashang:RemoveOnDeath()
    return false -- 死亡不移除
end

function modifier_gem_huihedashang:GetTexture()
    return "baowu/huihedashang"
end