LinkLuaModifier( "modifier_upgrade_damage_enhancement", "ability/upgrade/upgrade_damage_enhancement.lua",LUA_MODIFIER_MOTION_NONE )

if modifier_upgrade_damage_enhancement == nil then
	modifier_upgrade_damage_enhancement = {}
end

function modifier_upgrade_damage_enhancement:IsHidden()
	return true
end

function modifier_upgrade_damage_enhancement:GetAttributes()
	return  MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end

function modifier_upgrade_damage_enhancement:OnCreated()
end

function modifier_upgrade_damage_enhancement:OnRefresh()
	
	if IsServer() then
		self:IncrementStackCount()
	end
end
