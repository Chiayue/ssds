if modifier_gem_shanghaizengfu_taozhuang == nil then
	modifier_gem_shanghaizengfu_taozhuang = class({})
end

function modifier_gem_shanghaizengfu_taozhuang:DeclareFunctions()
    local funcs = {
    }
    return funcs
end

function modifier_gem_shanghaizengfu_taozhuang:IsHidden()
    return false
end

function modifier_gem_shanghaizengfu_taozhuang:OnCreated(params)
end

function modifier_gem_shanghaizengfu_taozhuang:IsPurgable()
    return false -- 无法驱散
end
 
function modifier_gem_shanghaizengfu_taozhuang:RemoveOnDeath()
    return false -- 死亡不移除
end

function modifier_gem_shanghaizengfu_taozhuang:GetTexture()
    return "baowu/shanghaizengfu"
end