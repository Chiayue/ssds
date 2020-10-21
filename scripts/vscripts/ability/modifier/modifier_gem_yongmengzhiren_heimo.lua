if modifier_gem_yongmengzhiren_heimo == nil then
	modifier_gem_yongmengzhiren_heimo = class({})
end

function modifier_gem_yongmengzhiren_heimo:DeclareFunctions()
    local funcs = {

    }
    return funcs
end

function modifier_gem_yongmengzhiren_heimo:IsHidden()
	return false
end

function modifier_gem_yongmengzhiren_heimo:OnCreated(params)
    
end

function modifier_gem_yongmengzhiren_heimo:IsPurgable()
    return false -- 无法驱散
end
 
function modifier_gem_yongmengzhiren_heimo:RemoveOnDeath()
    return false -- 死亡不移除
end

function modifier_gem_yongmengzhiren_heimo:GetTexture()
    return "antimage_mana_break"
end