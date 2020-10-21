if modifier_gem_shufuzhiren == nil then
	modifier_gem_shufuzhiren = class({})
end

function modifier_gem_shufuzhiren:DeclareFunctions()
    local funcs = {

    }
    return funcs
end

function modifier_gem_shufuzhiren:IsHidden()
	return false
end

function modifier_gem_shufuzhiren:OnCreated(params)
    
end

function modifier_gem_shufuzhiren:IsPurgable()
    return false -- 无法驱散
end
 
function modifier_gem_shufuzhiren:RemoveOnDeath()
    return false -- 死亡不移除
end

function modifier_gem_shufuzhiren:GetTexture()
    return "baowu/hufuzhiren"
end