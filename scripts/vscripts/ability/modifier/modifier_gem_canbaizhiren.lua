if modifier_gem_canbaizhiren == nil then
	modifier_gem_canbaizhiren = class({})
end

function modifier_gem_canbaizhiren:DeclareFunctions()
    local funcs = {

    }
    return funcs
end

function modifier_gem_canbaizhiren:IsHidden()
	return false
end

function modifier_gem_canbaizhiren:OnCreated(params)
    
end

function modifier_gem_canbaizhiren:IsPurgable()
    return false -- 无法驱散
end
 
function modifier_gem_canbaizhiren:RemoveOnDeath()
    return false -- 死亡不移除
end

function modifier_gem_canbaizhiren:GetTexture()
    return "baowu/canbaizhiren"
end