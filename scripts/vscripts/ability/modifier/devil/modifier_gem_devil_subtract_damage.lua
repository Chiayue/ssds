-- 减少94%伤害 modifier_gem_devil_subtract_damage

if modifier_gem_devil_subtract_damage == nil then 
    modifier_gem_devil_subtract_damage = class({}) 
end
function modifier_gem_devil_subtract_damage:IsHidden( ... ) 
    return true  
end

function modifier_gem_devil_subtract_damage:OnCreated( ... ) 

end

function modifier_gem_devil_subtract_damage:OnDestroy( ... ) 
    if not IsServer() then return end
    local hParent = self:GetParent()
    if hParent:IsAlive() then 
        --print("1")
        hParent:ForceKill(false)
        UTIL_Remove(hParent)
    end
end

function modifier_gem_devil_subtract_damage:DeclareFunctions( ... ) 
    return {MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE}
 end

function modifier_gem_devil_subtract_damage:GetModifierIncomingDamage_Percentage( ... ) 
    return -94
end