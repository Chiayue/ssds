if modifier_gem_yezhendebuyaole == nil then modifier_gem_yezhendebuyaole = class({}) end

function modifier_gem_yezhendebuyaole:GetAttributes()
    return  MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end

function modifier_gem_yezhendebuyaole:IsHidden()
    return false
end

function modifier_gem_yezhendebuyaole:IsPurgable()
    return false -- 无法驱散
end
 
function modifier_gem_yezhendebuyaole:RemoveOnDeath()
    return false -- 死亡不移除
end

function modifier_gem_yezhendebuyaole:OnRefresh()
    if not IsServer() then return end
    self:IncrementStackCount()
end


function modifier_gem_yezhendebuyaole:GetTexture()
    return "baowu/yezhendebuyaole"
end
