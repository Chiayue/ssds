if modifier_gem_duohunfazhang == nil then
	modifier_gem_duohunfazhang = class({})
end

function modifier_gem_duohunfazhang:DeclareFunctions()
    local funcs = {

    }
    return funcs
end

function modifier_gem_duohunfazhang:IsHidden()
	return false
end

function modifier_gem_duohunfazhang:OnCreated(params)
    
end

function modifier_gem_duohunfazhang:IsPurgable()
    return false -- 无法驱散
end
 
function modifier_gem_duohunfazhang:RemoveOnDeath()
    return false -- 死亡不移除
end

function modifier_gem_duohunfazhang:GetTexture()
    return "baowu/duohunfazhang"
end