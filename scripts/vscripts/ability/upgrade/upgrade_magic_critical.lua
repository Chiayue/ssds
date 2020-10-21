LinkLuaModifier( "modifier_Upgrade_Magic_Critical", "ability/upgrade/Upgrade_Magic_Critical.lua",LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_tech_max_magic_critical_buff", "ability/upgrade/Upgrade_Magic_Critical.lua",LUA_MODIFIER_MOTION_NONE )


if modifier_Upgrade_Magic_Critical == nil then
	modifier_Upgrade_Magic_Critical = {}
end

function modifier_Upgrade_Magic_Critical:IsHidden()
	return true
end

function modifier_Upgrade_Magic_Critical:GetTexture()
	return "fashubaoji"
end

function modifier_Upgrade_Magic_Critical:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK
	}
	return funcs
end

function modifier_Upgrade_Magic_Critical:GetAttributes()
	return  MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end

function modifier_Upgrade_Magic_Critical:OnCreated()
end

function modifier_Upgrade_Magic_Critical:OnRefresh()
	if IsServer() then
		self:IncrementStackCount()
	end
end

function modifier_Upgrade_Magic_Critical:OnAttack(keys)
	if not IsServer() then return end
	if self:GetStackCount() ~= 10 then return end
	if keys.attacker == self:GetParent()  then
		local hCaster = self:GetCaster()
		local nChance = RandomInt(0,100)
		if nChance > 3 then
			return 0
		end
		
		hCaster:AddNewModifier( 
			hCaster, 
			self:GetAbility(), 
			"modifier_tech_max_magic_critical_buff", 
			{ duration = 5} 
		)
	end
end

if modifier_tech_max_magic_critical_buff == nil then
	modifier_tech_max_magic_critical_buff = class({})
end
function modifier_tech_max_magic_critical_buff:DeclareFunctions() return { MODIFIER_PROPERTY_TOOLTIP } end
function modifier_tech_max_magic_critical_buff:OnTooltip() return self:GetStackCount() * 3 end

function modifier_tech_max_magic_critical_buff:OnCreated()
	if not IsServer() then return end
	self:SetStackCount(1)
end

function modifier_tech_max_magic_critical_buff:OnRefresh()
	if not IsServer() then return end
	if self:GetStackCount() < 5 then
		self:IncrementStackCount()
	else
		self:SetStackCount( self:GetStackCount() )
	end
	self:SetDuration( 5, true )
end

function modifier_tech_max_magic_critical_buff:IsHidden()
	return ( self:GetStackCount() == 0 )
end

function modifier_tech_max_magic_critical_buff:GetTexture()
	return "fashubaoji"
end
