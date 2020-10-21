if ability_damage_box == nil then
	ability_damage_box = class({})
end
LinkLuaModifier( "modifier_ability_damage_box", "ability/creatures/ability_damage_box.lua", LUA_MODIFIER_MOTION_NONE )

function ability_damage_box:GetIntrinsicModifierName()
	return "modifier_ability_damage_box"
end

--------------------------------------------------------------------------------

if modifier_ability_damage_box == nil then
	modifier_ability_damage_box = class({})
end

function modifier_ability_damage_box:IsHidden()
	return true
end

function modifier_ability_damage_box:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_ability_damage_box:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MIN_HEALTH,
    }
    return funcs
end

-- function modifier_ability_damage_box:OnCreated( kv )
-- 	self:StartIntervalThink( 0.01 )
-- end

-- function modifier_ability_damage_box:OnIntervalThink()
--     self.min_health = self:GetAbility():GetSpecialValueFor( "min_health" ) 
-- 	self:StartIntervalThink(-1)
-- end

function modifier_ability_damage_box:GetMinHealth( params )
	return 1
end