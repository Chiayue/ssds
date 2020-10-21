if modifier_gem_yongmengzhiren_da == nil then
	modifier_gem_yongmengzhiren_da = class({})
end

function modifier_gem_yongmengzhiren_da:DeclareFunctions()
    local funcs = {

    }
    return funcs
end

function modifier_gem_yongmengzhiren_da:IsHidden()
	if self:GetCaster():HasModifier( "modifier_gem_yongmengzhiren_heimo" ) then
        return true
    else
        return false
    end
end

function modifier_gem_yongmengzhiren_da:OnCreated(params)
    if IsServer() then
        local hero = self:GetParent()
        if hero:HasModifier("modifier_gem_yongmengzhiren_xiao") and hero:HasModifier("modifier_gem_yongmengzhiren_zhong")  and not hero:HasModifier("modifier_gem_yongmengzhiren_heimo") then
            hero:AddNewModifier( hero, nil, "modifier_gem_yongmengzhiren_heimo", {} )
        end
    end
end

function modifier_gem_yongmengzhiren_da:IsPurgable()
    return false -- 无法驱散
end
 
function modifier_gem_yongmengzhiren_da:RemoveOnDeath()
    return false -- 死亡不移除
end

function modifier_gem_yongmengzhiren_da:GetTexture()
    return "baowu/dayongmengzhiren"
end