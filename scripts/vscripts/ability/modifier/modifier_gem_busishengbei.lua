if modifier_gem_busishengbei == nil then
	modifier_gem_busishengbei = class({})
end

function modifier_gem_busishengbei:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_DEATH,
    }
    return funcs
end

function modifier_gem_busishengbei:IsHidden()
	return false
end

function modifier_gem_busishengbei:OnCreated(params)

end

function modifier_gem_busishengbei:OnDeath(args)
    local nCaster = self:GetParent()
    if nCaster:IsAlive() == false and nCaster:IsIllusion() == false and nCaster:IsHero() then
        nCaster:RespawnHero(true,true)
    end
end

function modifier_gem_busishengbei:IsPurgable()
    return false -- 无法驱散
end
 
function modifier_gem_busishengbei:RemoveOnDeath()
    return true -- 死亡移除
end

function modifier_gem_busishengbei:GetTexture(  )
    return "baowu/busishengbei"
end
