if modifier_gem_yongmengzhiren_zhong == nil then
	modifier_gem_yongmengzhiren_zhong = class({})
end

function modifier_gem_yongmengzhiren_zhong:DeclareFunctions()
    local funcs = {

    }
    return funcs
end

function modifier_gem_yongmengzhiren_zhong:IsHidden()
    if self:GetCaster():HasModifier( "modifier_gem_yongmengzhiren_heimo" ) then
        return true
    else
        return false
    end
end

function modifier_gem_yongmengzhiren_zhong:OnCreated(params)
    if IsServer() then
        local hero = self:GetParent()
        if hero:HasModifier("modifier_gem_yongmengzhiren_xiao") and hero:HasModifier("modifier_gem_yongmengzhiren_da")  and not hero:HasModifier("modifier_gem_yongmengzhiren_heimo") then
            hero:AddNewModifier( hero, nil, "modifier_gem_yongmengzhiren_heimo", {} )
        end
    end
end

function modifier_gem_yongmengzhiren_zhong:IsPurgable()
    return false -- 无法驱散
end
 
function modifier_gem_yongmengzhiren_zhong:RemoveOnDeath()
    return false -- 死亡不移除
end

function modifier_gem_yongmengzhiren_zhong:GetTexture()
    return "baowu/zhongyongmengzhiren"
end