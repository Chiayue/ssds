LinkLuaModifier( "modifier_Upgrade_Physical_Critical_Damage", "ability/upgrade/Upgrade_Physical_Critical_Damage.lua",LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_tech_max_physical_critical_damage_buff", "ability/upgrade/Upgrade_Physical_Critical_Damage", LUA_MODIFIER_MOTION_NONE)

if modifier_Upgrade_Physical_Critical_Damage == nil then
	modifier_Upgrade_Physical_Critical_Damage = {}
end

function modifier_Upgrade_Physical_Critical_Damage:IsHidden()
	return true
end

function modifier_Upgrade_Physical_Critical_Damage:GetAttributes()
	return  MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end

function modifier_Upgrade_Physical_Critical_Damage:OnCreated()
end

function modifier_Upgrade_Physical_Critical_Damage:OnRefresh()
	if IsServer() then
		self:IncrementStackCount()
	end
	
end

function modifier_Upgrade_Physical_Critical_Damage:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK
	}
	return funcs
end

function modifier_Upgrade_Physical_Critical_Damage:OnAttack(keys)
	if not IsServer() then return end
	if self:GetStackCount() ~= 10 then return end
	-- Make sure the attacker and target are valid
	if keys.attacker == self:GetParent()  then
		local hCaster = self:GetCaster()
		local nChance = RandomInt(0,100)
		if nChance > 3 then
			return 0
		end
		
		hCaster:AddNewModifier( 
			hCaster, 
			self:GetAbility(), 
			"modifier_tech_max_physical_critical_damage_buff", 
			{ duration = 5} 
		)
	end
end

if modifier_tech_max_physical_critical_damage_buff == nil then
	modifier_tech_max_physical_critical_damage_buff = class({})
end
function modifier_tech_max_physical_critical_damage_buff:DeclareFunctions() return { MODIFIER_PROPERTY_TOOLTIP } end
function modifier_tech_max_physical_critical_damage_buff:OnTooltip() return self:GetStackCount() * 25 end
function modifier_tech_max_physical_critical_damage_buff:OnCreated()
	self:SetStackCount(1)
end

function modifier_tech_max_physical_critical_damage_buff:OnRefresh()
	if not IsServer() then return end
	if self:GetStackCount() < 5 then
		self:IncrementStackCount()
	else
		self:SetStackCount( self:GetStackCount() )
	end
	self:SetDuration( 5, true )
end

function modifier_tech_max_physical_critical_damage_buff:IsHidden()
	return ( self:GetStackCount() == 0 )
end

function modifier_tech_max_physical_critical_damage_buff:GetTexture()
	return "wulibaojishanghai"
end