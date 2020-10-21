if modifier_gem_yongmengzhiren_xiao == nil then
	modifier_gem_yongmengzhiren_xiao = class({})
end

function modifier_gem_yongmengzhiren_xiao:DeclareFunctions()
    local funcs = {

    }
    return funcs
end

function modifier_gem_yongmengzhiren_xiao:IsHidden()
	if self:GetCaster():HasModifier( "modifier_gem_yongmengzhiren_heimo" ) then
        return true
    else
        return false
    end
end

function modifier_gem_yongmengzhiren_xiao:OnCreated(params)
    if IsServer() then
        local hero = self:GetParent()
        if hero:HasModifier("modifier_gem_yongmengzhiren_zhong") and hero:HasModifier("modifier_gem_yongmengzhiren_da")  and not hero:HasModifier("modifier_gem_yongmengzhiren_heimo") then
            hero:AddNewModifier( hero, nil, "modifier_gem_yongmengzhiren_heimo", {} )
        end
    end
end

function modifier_gem_yongmengzhiren_xiao:IsPurgable()
    return false -- 无法驱散
end
 
function modifier_gem_yongmengzhiren_xiao:RemoveOnDeath()
    return false -- 死亡不移除
end

function modifier_gem_yongmengzhiren_xiao:GetTexture()
    return "baowu/xiaoyongmengzhiren"
end